#!/usr/bin/python
from multiprocessing import Process, Queue
from Queue import Empty
import subprocess
from lockss_util import getAUIDList, getFileString, makeFileDictList
import lockssbagger
import cPickle as pickle
import logging
import datetime
import time
import os
import hashlib
import shutil
import sys
import re
import pprint
from optparse import OptionParser

bagUtil = "/home/knordstrom/bagit-3.4/bin/bag"

LOGPATH = ""
LOGFILE = None

def fillHoleyBag(bagPath):
    """
    Use the bag utility to fill a holey bag
    """
    cmdList = [ bagUtil, "fillholey", bagPath ]
    try:
        subprocess.check_call(cmdList)    
    except subprocess.CalledProcessError, c:
        return False
    return True

def completeBag(bagPath):
    """
    Use the bag utility to complete a filled bag
    """
    cmdList = [ bagUtil, "updatetagmanifests", bagPath ]
    try:
        subprocess.check_call(cmdList)    
    except subprocess.CalledProcessError, c:
        return False
    return True

def _completeBag(bagPath):
    """
    Use the bag utility to complete a filled bag
    """
    cmdList = [ bagUtil, "makecomplete", bagPath ]
    try:
        subprocess.check_call(cmdList)    
    except subprocess.CalledProcessError, c:
        return False
    return True
    
def verifyBag(bagPath):
    """
    Use the bag utility to verify a filled bag
    """
    cmdList = [ bagUtil, "verifyvalid", bagPath ]
    try:
        bagProc = subprocess.Popen(cmdList, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except Exception, e:
        sys.stderr.write("Error validating bag %s: %s\n" % (bagPath, e))
        return False
    
    output = bagProc.communicate()[1]
    
    if not output or output.strip() != "Result is true.":
        sys.stderr.write("Bag at %s did not validate:\n%s\n" % (bagPath, output))
        return False
    
    return True
    

def calculateSize(lockssURL, name, password, collectionFilter):
    rawAuidList = getAUIDList(lockssURL, name, password)
    print("Total number of AUIDs in LOCKSS cache is %s" % len(rawAuidList))
    auidList = []
    for auid in rawAuidList:
        if auid.startswith(collectionFilter):
            auidList.append(auid)
    print("Number of AUIDs that begin with '%s'is %s" % (collectionFilter, len(auidList)))
    totalSize = 0L
    for auid in auidList:
        auidTotal = 0L
        fileString = getFileString(lockssURL, auid, name, password)
        fileDictList = makeFileDictList(fileString, "")
        for fileDict in fileDictList:
            auidTotal = auidTotal + fileDict["size"]
        print("Size of files in auid %s is %s" % (auid, auidTotal))
        totalSize = totalSize + auidTotal
            
    return totalSize


def makeSizeList(lockssURL, name, password, limit, collectionFilter=None):
    rawAuidList = getAUIDList(lockssURL, name, password)
    auidList = []
    if collectionFilter:
        regObject = re.compile(collectionFilter)
        for auid in rawAuidList:
            if regObject.match(auid):
                auidList.append(auid)
    else:
        auidList = rawAuidList
        
    totalSize = 0L
    collectedAuids = []
    for auid in auidList:
        auidTotal = 0L
        fileString = getFileString(lockssURL, auid, name, password)
        fileDictList = makeFileDictList(fileString, "")
        for fileDict in fileDictList:
            auidTotal = auidTotal + fileDict["size"]
        if totalSize + auidTotal > limit:
            break
        totalSize = totalSize + auidTotal
        collectedAuids.append(auid)
    
    return collectedAuids

    
    
def setupState(lockssURL, name, password, remoteDir, workingDir, stateFile, logFile, filter=None):
    """
    Build our initial state for running a transfer
    """
    state = {}
    rawAuidList = getAUIDList(lockssURL, name, password)
    filteredAuidList = []
    if filter:
        regObject = re.compile(filter)
        for auid in rawAuidList:
            #if auid.startswith(filter):
            if regObject.match(auid):
                filteredAuidList.append(auid)
        state["auidList"] = filteredAuidList
    else:
       state["auidList"] = rawAuidList
    state["failList"] = []
    state["completedList"] = []
    state["workingDir"] = workingDir
    state["logFile"] = logFile
    state["remoteDir"] = remoteDir
    state["filter"] = filter
    
    fileOb = open(stateFile, "w") 
    pickle.dump(state, fileOb)
    fileOb.close()
    
   
def transferBatch(lockssURL, name, password, stateFile, workerCount=1, filled=True, proxyURL=None):
    """
    Manage a bunch of batch exports, validations and transfers.
    """
    #read in the statefile
    fileOb = open(stateFile, "r")
    state = pickle.load(fileOb) 
    fileOb.close()
    #workerCount = 3
    logging.basicConfig(filename=state["logFile"],level=logging.INFO)
    global LOGPATH
    LOGPATH = state["logFile"]
    messageQueue = Queue()
    currentWorkers = {}
    irodsOb = IRodsClient(ilsPath = "/home/knordstrom/iRODS/clients/icommands/bin/ils", icdPath = "/home/knordstrom/iRODS/clients/icommands/bin/icd", \
        iputPath = "/home/knordstrom/iRODS/clients/icommands/bin/iput", icheckPath = "/home/knordstrom/iRODS/clients/icommands/bin/ichksum" )
    while True: #repeat indefinitely?
        while len(state["auidList"]) and len(currentWorkers) < workerCount:
            print "The worker count is currently %s out of a max of %s.  The number of AUIDs to process is %s." % (len(currentWorkers), workerCount, len(state["auidList"]))
            for y in range(len(state["auidList"])):
                auid = state["auidList"][y]
                if not auid in currentWorkers:
                    auidParts = auid.split("~")
                    localFile = os.path.join(state["workingDir"], auidParts[-1])
                    print("Creating new worker to handle auid %s" % auid)
                    newWorker = Process(target = handleAUID, 
                        args = (lockssURL, name, password, auid, localFile, state["remoteDir"], irodsOb, messageQueue, filled, proxyURL) )
                    currentWorkers[auid] = newWorker
                    newWorker.start()
                else:
                   print("auid %s is already being handled" % auid)
                   if len(state["auidList"]) - workerCount < 1:
                       time.sleep(15) #no sense burning cycles here

                if len(currentWorkers) >= workerCount:
                    break
        #if we have no workers at this point, we're done!  Break out of the function
        if len(currentWorkers) == 0:
            return
                
        #check for queue messages to log
        while not messageQueue.empty():
            try:
                entry = messageQueue.get()
                if type(entry) == type(()):
                    logMessage(entry[0], entry[1])
                else:
                    logMessage(entry)
            except Empty:
                break
        
        #check for finished workers, remove from queue and remove auid from list.  Write statefile.
        auidList = currentWorkers.keys()
        for auid in auidList:
            worker = currentWorkers[auid]
            if worker.is_alive():
                continue
            del(currentWorkers[auid])
            #some way to check for exit code here?
            state["auidList"].remove(auid)
            if worker.exitcode != 0:
                state["failList"].append(auid)
            fileOb = open(stateFile, "w")
            pickle.dump(state, fileOb)
            fileOb.close()
            
        time.sleep(1) #hopefully this will keep us from burning too much CPU

    fileOb = open(stateFile, "w")
    pickle.dump(state, fileOb)
    fileOb.close()
     
def _transferBatch(lockssURL, name, password, stateFile, workerCount=1, filled=True, proxyURL=None):
    """
    Manage a bunch of batch exports, validations and transfers.
    """
    #read in the statefile
    fileOb = open(stateFile, "r")
    state = pickle.load(fileOb) 
    fileOb.close()
    #workerCount = 3
    logging.basicConfig(filename=state["logFile"],level=logging.INFO)
    messageQueue = Queue()
    currentWorkers = {}
    irodsOb = IRodsClient(ilsPath = "/home/knordstrom/iRODS/clients/icommands/bin/ils", icdPath = "/home/knordstrom/iRODS/clients/icommands/bin/icd", \
        iputPath = "/home/knordstrom/iRODS/clients/icommands/bin/iput", icheckPath = "/home/knordstrom/iRODS/clients/icommands/bin/ichksum" )
    while True: #repeat indefinitely?
        while len(state["auidList"]) and len(currentWorkers) < workerCount and len(currentWorkers) < len(state["auidList"]):
            print "The worker count is currently %s out of a max of %s.  The number of AUIDs to process is %s." % (len(currentWorkers), workerCount, len(state["auidList"]))
            for y in range(len(state["auidList"])):
                auid = state["auidList"][y]
                if not auid in currentWorkers:
                    auidParts = auid.split("~")
                    localFile = os.path.join(state["workingDir"], auidParts[-1])
                    print("Creating new worker to handle auid %s" % auid)
                    newWorker = Process(target = handleAUID, 
                        args = (lockssURL, name, password, auid, localFile, state["remoteDir"], irodsOb, messageQueue, filled, proxyURL) )
                    currentWorkers[auid] = newWorker
                    newWorker.start()
                else:
                   print("auid %s is already being handled" % auid)
                if len(currentWorkers) >= workerCount:
                    break
        #if we have no workers at this point, we're done!  Break out of the function
        if len(currentWorkers) == 0:
            return
                
        #check for queue messages to log
        while not messageQueue.empty():
            try:
                entry = messageQueue.get()
                logMessage(entry[0], entry[1])
            except Queue.Empty:
                break
        
        #check for finished workers, remove from queue and remove auid from list.  Write statefile.
        auidList = currentWorkers.keys()
        for auid in auidList:
            worker = currentWorkers[auid]
            if worker.is_alive():
                continue
            del(currentWorkers[auid])
            #some way to check for exit code here?
            state["auidList"].remove(auid)
            if worker.exitcode != 0:
                state["failList"].append(auid)
            fileOb = open(stateFile, "w")
            pickle.dump(state, fileOb)
            fileOb.close()
            
        time.sleep(1) #hopefully this will keep us from burning too much CPU

    fileOb = open(stateFile, "w")
    pickle.dump(state, fileOb)
    fileOb.close()
        
        
  
def logMessage( message, time=datetime.datetime.now()):
    """
    Log a message
    """
    logEntry = "%s %s" % (time.strftime("%Y-%m-%dT%H:%M:%S"), message)
    #logging.info(logEntry)
    print("Logging %s" % logEntry)
    global LOGFILE
    global LOGPATH
    if not LOGFILE:
        LOGFILE = open(LOGPATH, "a")
    LOGFILE.write(logEntry + "\n")
    LOGFILE.flush()
      
def _logMessage( message, time=datetime.datetime.now()):
    """
    Log a message
    """
    logEntry = "%s %s" % (time.strftime("%Y-%m-%dT%H:%M:%S"), message)
    logging.info(logEntry)
    
def handleAUID(lockssURL, name, password, auid, localFile, remoteDir, iRodsObject, queue, filled=True, proxyURL=None):
    """
    This is the function called by the "worker process""
    """
    if os.path.exists(localFile):
        raise Exception("Local file %s already exists." % localFile)
    
    os.makedirs(localFile)
    startTime = datetime.datetime.now()
    queue.put( ("Creating local copy of bag from auid %s to local directory %s" % (auid, localFile), startTime) )
    #lockssbagger.makeBagFromAUID(lockssURL, auid, name, password, localFile, None, False) #we can do unfilled now
    lockssbagger.makeBagFromAUID(lockssURL, auid, name, password, localFile, proxyURL, filled) 
    if filled:
        if not fillHoleyBag(localFile):
            queue.put("Error filling bag %s" % localFile)
            return
    completeBag(localFile)
    if filled:
        if not verifyBag(localFile):
            queue.put("Error validating bag %s" % localFile)
            return
    localName = os.path.split(localFile)[1]
    remoteName = os.path.join(remoteDir, localName)
    #sendOverIRods(localFile, remoteDir, localName)
    queue.put( ("Transferring local directory %s to %s directory via iRods" % (localFile, remoteName), datetime.datetime.now()))
    iRodsObject.cd(remoteDir)
    iRodsObject.put(localFile, remoteName)
    queue.put( ("Comparing remote and local checksums for auid %s" % auid, datetime.datetime.now()))
    remoteChecksumString = iRodsObject.check(remoteName)
    localChecksumString = getLocalChecksum(localFile)
    remoteDict = parseRemoteChecksum(remoteChecksumString, remoteName)
    localDict = parseLocalChecksum(localChecksumString, localFile)
    files = localDict.keys()
    for fileName in files:
        if fileName in localDict and fileName in remoteDict and localDict[fileName] != remoteDict[fileName]:
            raise Exception("Hash values for %s do not match! %s (remote), %s (local)" \
                % (fileName, localDict[fileName], remoteDict[fileName]))
                
    endTime = datetime.datetime.now()
    queue.put( ("Operations for auid %s are complete" % auid, endTime ) )
    timeDelt = endTime - startTime
    minutes = timeDelt.seconds / 60
    seconds = timeDelt.seconds - ( minutes * 60 )
    queue.put( ("auid %s took %s minutes and %s seconds to process" % (auid, minutes, seconds), endTime) )
    
    if filled: #cleanup if we're generating a lot of extra files
        shutil.rmtree(localFile)
            
    #validateTransfer(localFile, remoteDir, localName)
    
class IRodsClient(object):
    """
    An object representing an iRods environment
    """
    def __init__(self, ilsPath, icdPath, iputPath, icheckPath):
        self.ilsPath = ilsPath
        self.icdPath = icdPath
        self.iputPath = iputPath
        self.icheckPath = icheckPath
        
    def ls(self, remoteDirectory=""):
        """
        Return a list of lists...the first being a list of regular files in
        the directory, and the second being the of directories
        """
        commandList = [ self.ilsPath, remoteDirectory ]
        proc = subprocess.Popen(commandList, stdout=subprocess.PIPE)
        proc.wait()
        output = proc.stdout.read()
        fileList = []
        dirList = []
        outLines = output.splitlines()
        for line in outLines:
            if not line.startswith("C-"):
                fileList.append(line)
            else:
                parts = line.split()
                dirName = os.path.split(parts[1])[1]
                dirList.append(dirName)
        return ( fileList, dirList )
    
    def cd(self, remoteDirectory=""):
        """
        Execute a remote directory change
        """
        commandList = [ self.icdPath, remoteDirectory ]
        proc = subprocess.Popen(commandList, stdout=subprocess.PIPE)
        proc.wait()
        output = proc.stdout.read()
        if output and output.startswith("No such directory"):
            raise Exception("Invalid directory")
        
    def put(self, localFile, remoteFile=""):
        commandList = [ self.iputPath, "-r", "-R", "SAMqfs", localFile, remoteFile ]
        proc = subprocess.Popen(commandList, stdout=subprocess.PIPE)
        proc.wait()
        
    def check(self, remoteFile):
        """
        Perform a recursive checksum of a remote file/dir
        """
        commandList = [ self.icheckPath, "-r", remoteFile ]
        proc = subprocess.Popen(commandList, stdout=subprocess.PIPE)
        proc.wait()
        output = proc.stdout.read()
        return output
    
        
    
def sendOverIRods(localFile, remoteDir, localName):
    """
    Handle the actual sending of stuff over the iRods command line client
    """
    
def parseRemoteChecksum(checkString, remoteDir):
    lines = checkString.splitlines()
    directory = ""
    fileDict = {}
    for x in range(len(lines)):
        line = lines[x]
        if line.startswith("C-"):
            rawDirectory = line.split(None,1)[1]
            if rawDirectory.find(remoteDir) != 0:
                raise Exception("%s is not found in directory %s" % (remoteDir, rawDirectory))
            localPart = rawDirectory[len(remoteDir):]
            localPart = localPart.rstrip(":")
            localPart = localPart.lstrip("/")
            directory = localPart
        else:
            parts = line.split()
            fileName = parts[0]
            hash = parts[1]
            fullName = os.path.join(directory, fileName)
            fileDict[fullName] = hash
    return fileDict

def parseLocalChecksum(checkString, localDir):
    fileDict = {}
    lines = checkString.splitlines()
    for line in lines:
        hash,fileName = line.split()
        if fileName.find(localDir) != 0:
            raise Exception("%s is not found in directory %s" % (localDir, fileName))
        localPart = fileName[len(localDir):]
        localPart = localPart.lstrip("/")
        fileDict[localPart] = hash
    return fileDict

def _getLocalChecksum(localDir):
    commandList = [ "find", localDir, "-type", "f", "2>/dev/null", "-exec", "md5sum", "{}", "\;" ]
    proc = subprocess.Popen(commandList, stdout=subprocess.PIPE)
    proc.wait()
    output = proc.stdout.read()
    return output

def getLocalChecksum(localDir):
    hashList = []
    for root,dirs,fileNames in os.walk(localDir):
        for fileName in fileNames:
            filePath = os.path.join(root, fileName)
            md5 = hashlib.md5()
            readFile = open(filePath, "r")
            chunk = readFile.read(2048)
            while chunk:
                md5.update(chunk)
                chunk = readFile.read(2048)
            hashList.append("%s  %s" % (md5.hexdigest(), filePath))
    return "\n".join(hashList)


configOptionsDict = {
    "lockss_url" : ["lockss-url", "l", "The URL of our LOCKSS cache", True],
    "working_dir" : [ "working-dir", "w", "The local working directory that we store our statefile and logs in", True],
    "lockss_username" : [ "username", "u", "The username for the LOCKSS cache", True],
    "lockss_password" : [ "password", "p", "The password for the LOCKSS cache", True],
    "proxy_url" : [ "proxy-url", "P", "The URL for the LOCKSS file proxy (needed for holey bags)", False],
    "remote_irods_dir" : [ "remote-dir", "r", "The remote iRods directory", True],
    "worker_count" : [ "worker-count", "W", "The number of worker processes to spawn (minimum 1)", False],
    "au_filter" : [ "filter", "F", "A regular expression string to filter out the AUs that we're looking to use", False],
    
}


def readConfig(configPath):
    """
    Attempt to eval a file defined at configPath and return the result dictionary.
    Check for certain needed values and raise exceptions if errors or missing values.
    """
    
    if not os.path.exists(configPath):
        sys.stderr.write("No configFile found at %s\n" % configPath)
        return {}
    
    locals = {}
    
    execfile(configPath, {}, locals)
    
    #checkKeys = [
    #    "username",
    #    "password",
    #    "lockss_url",
    #    "proxy_url",
    #]
    
    checkKeys = [] #no required keys at this time
    
    if not "config" in locals:
        raise Exception("Config file %s is not properly formatted" % configPath)
    
    config = locals["config"]
    
    for key in checkKeys:
        if not key in config or not config[key]:
            raise Exception("Missing required key '%s' from configuration file %s" %
                (key, configPath))
        
    return config

if __name__ == "__main__":
    
    usage = "usage: %prog [options] run"
    
    parser = OptionParser(usage=usage)
    parser.add_option("-c", "--config", action="store", type="string",
        dest="config", help="Specify an alternate configuration file")
    
    #add our automatic config options here
    for remoteName, localList in configOptionsDict.iteritems():
        parser.add_option("-" + localList[1], "--" + localList[0], \
            action="store", type="string", dest=localList[0], \
            help=localList[2])
            
        
    
    parser.add_option("-f", "--fill", action="store_true",  dest="fill", 
        help="Create filled bags, as opposed to a holey bags" ) 
        
    (options, args) = parser.parse_args()
    
    if len(args) < 1 or args[0] != "run":
        parser.print_help()
        sys.exit(1)
        
    #determine config file location, load it
    if options.config:
        configPath = options.config
    else:
        configPath = os.path.join(os.environ["HOME"], ".locksstool")
        
    configDict = readConfig(configPath)
        
    #determine essential options, raise issues if missing
    
    for configName, localList in configOptionsDict.iteritems():
        localConfigName = localList[0]
        if localList[3] == True: #is it required
            if ( not hasattr(options, localConfigName) or not getattr(options, localConfigName) ) and not configName in configDict:
                raise Exception, "%s is needed to proceed, but is not defined" % configName
        if hasattr(options, localConfigName) and getattr(options, localConfigName):
            #print "Looking to sync %s with %s" % (localConfigName, configName)
            #if not configName in configDict or not configDict[configName]:
            configDict[configName] = getattr(options, localConfigName)
           
    pprint.pprint(configDict)
    
    if options.fill:
        if not "proxy_url" in configDict:
            raise Exception, "If you are generating holey bags, you must specify the proxy_url for your LOCKSS cache"
        
    auFilter = None
    if "au_filter" in configDict:
        auFilter = configDict["au_filter"]


    workingDir = configDict["working_dir"]

    stateFile = os.path.join(workingDir, "state_file")
    logFile = os.path.join(workingDir, "log_file")
    
    filled=False
    
    if options.fill:
        filled = True
    
    workerCount = 1
    if "worker_count" in configDict:
        try:
            workerCount = int(configDict["worker_count"])
        except:
            print "Unable to resolve worker count from the value %s" % configDict["worker_count"]    
    
    #if stateFile exists, use it. Otherwise call setupState
    
    if not os.path.exists(stateFile):
        print("Calling setupState with lockssURL=%s, name=%s, password=%s, remoteDir=%s, workingDir=%s, stateFile=%s, logFile=%s, filter=%s" % \
            ( configDict["lockss_url"], configDict["lockss_username"], configDict["lockss_password"], configDict["remote_irods_dir"],\
              workingDir, stateFile, logFile, auFilter))
            
        setupState(lockssURL = configDict["lockss_url"], name = configDict["lockss_username"], \
            password = configDict["lockss_password"], remoteDir = configDict["remote_irods_dir"], \
            workingDir = workingDir, stateFile = stateFile, logFile = logFile, \
            filter = auFilter)
        
    
    transferBatch( lockssURL = configDict["lockss_url"], name = configDict["lockss_username"], \
        password = configDict["lockss_password"], stateFile = stateFile, workerCount = workerCount, \
        proxyURL = configDict["proxy_url"], filled=filled )
        
    
        
    
    
            
        
          
    
    
