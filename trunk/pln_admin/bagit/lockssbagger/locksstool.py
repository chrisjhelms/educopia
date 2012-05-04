#!/usr/bin/python
from multiprocessing import Process, Queue
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

bagUtil = "/home/knordstrom/bagit-3.4/bin/bag"

def fillHoleyBag(bagPath):
    """
    Use the bag utility to fill a holey bag
    """
    cmdList = [ bagUtil, "fillholey", bagPath ]
    try:
        subprocess.check_call(cmdList)    
    except subprocess.CallProcessError, c:
        return False
    return True

def completeBag(bagPath):
    """
    Use the bag utility to complete a filled bag
    """
    cmdList = [ bagUtil, "makecomplete", bagPath ]
    try:
        subprocess.check_call(cmdList)    
    except subprocess.CallProcessError, c:
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

    
    
def setupState(lockssURL, name, password, remoteDir, workingDir, stateFile, logFile, filter=None):
    """
    Build our initial state for running a transfer
    """
    state = {}
    rawAuidList = getAUIDList(lockssURL, name, password)
    filteredAuidList = []
    if filter:
       for auid in rawAuidList:
           if auid.startswith(filter):
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
    
    
def transferBatch(lockssURL, name, password, stateFile, workerCount=1):
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
        while len(state["auidList"]) and len(currentWorkers) < workerCount:
            print "The worker count is currently %s out of a max of %s.  The number of AUIDs to process is %s." % (len(currentWorkers), workerCount, len(state["auidList"]))
            for y in range(len(state["auidList"])):
                auid = state["auidList"][y]
                if not auid in currentWorkers:
                    auidParts = auid.split("~")
                    localFile = os.path.join(state["workingDir"], auidParts[-1])
                    print("Creating new worker to handle auid %s" % auid)
                    newWorker = Process(target = handleAUID, 
                        args = (lockssURL, name, password, auid, localFile, state["remoteDir"], irodsOb, messageQueue) )
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
    logging.info(logEntry)
    
def handleAUID(lockssURL, name, password, auid, localFile, remoteDir, iRodsObject, queue):
    """
    This is the function called by the "worker process""
    """
    if os.path.exists(localFile):
        raise Exception("Local file %s already exists." % localFile)
    
    os.makedirs(localFile)
    startTime = datetime.datetime.now()
    queue.put( ("Creating local copy of bag from auid %s to local directory %s" % (auid, localFile), startTime) )
    lockssbagger.makeBagFromAUID(lockssURL, auid, name, password, localFile, None, False) #we can do unfilled now
    if not fillHoleyBag(localFile):
        queue.put("Error filling bag %s" % localFile)
        return
    completeBag(localFile)
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
          
    
    
