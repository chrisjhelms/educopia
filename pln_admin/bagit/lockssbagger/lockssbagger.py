#!/usr/bin/python
import os
import sys
import urlparse
import urllib
import hashlib
import httplib2
import time
import pprint
import subprocess
from optparse import OptionParser
import BeautifulSoup as BS
from coda import anvl
from lockss_util import requestHash, getHashLink, retrieveURL, retrieveBigURL, getHashString, getFileString, makeFileDictList

    
def makeBag(auid, fileDictList, bagPath, fetchProxy = None, bagInfoOriginal = None, fill = False):
    """
    Make a new bag based on the file list downloaded from the AU view in the
    LOCKSS admin console, and the hash file based on the V3 hash on an entire
    AU.  The new bag is created at bagPath
    """
    bagInfoDict = {}    
    if bagInfoOriginal:
        bagInfoDict.update(bagInfoOriginal)
    manifestLines = []
    fetchLines = []
    #let's make the actual bag here
    if not os.path.exists(bagPath):
        os.mkdir(bagPath)
    bagData = os.path.join(bagPath, "data")
    if not os.path.exists(bagData):
        os.mkdir(bagData)
    bagBagit = os.path.join(bagPath, "bagit.txt")
    bagManifest = os.path.join(bagPath, "manifest-sha1.txt")
    bagFetch = os.path.join(bagPath, "fetch.txt")
    bagInfo = os.path.join(bagPath, "bag-info.txt")

    for fileDict in fileDictList:
        localPath = os.path.join("data", fileDict["path"])
        localName = os.path.join(localPath, fileDict["name"])
        manifestEntry = "%s  %s" % ( fileDict["digest"], localName ) #need exactly two spaces between hash and filename
        manifestLines.append(manifestEntry)
        if fetchProxy:
            fetchURL = "%s?url=%s&norewrite=1&auid=%s" % ( fetchProxy, urllib.quote(fileDict['url']), urllib.quote(auid))
        else:
            fetchURL = fileDict['url']
        fetchEntry = "%s %s %s" % ( fetchURL, fileDict["size"], localName )
        fetchLines.append(fetchEntry)
        
    #pprint.pprint(fetchLines)
    #pprint.pprint(manifestLines)
    
    #populate bag-info here with Payload-Oxum, Bag-Size and Bagging-Date
    bagInfoDict["Bagging-Date"] = time.strftime("%Y-%m-%d", time.gmtime())
    
    bagBagitFile = open(bagBagit, "w")
    bagBagitFile.write("BagIt-Version: 0.96\nTag-File-Character-Encoding: UTF-8\n")
    bagBagitFile.close()
    
    bagManifestFile = open(bagManifest, "w")
    for manifestLine in manifestLines:
        bagManifestFile.write(manifestLine + "\n")
    bagManifestFile.close()
    
    if not fill:
        bagFetchFile = open(bagFetch, "w")
        for fetchLine in fetchLines:
            bagFetchFile.write(fetchLine + "\n")
        bagFetchFile.close()
        
    bagInfoFile = open(bagInfo, "w")
    bagInfoFile.write(anvl.writeANVLString(bagInfoDict))
    bagInfoFile.close()
    
def fillBag(lockssURL, fileDictList, auid, bagPath, name, password):
    urlBase = urlparse.urljoin(lockssURL, "ViewContent")
    for fileDict in fileDictList:
        urlParts = {}
        localPath = os.path.join(bagPath, os.path.join("data", fileDict["path"]))
        localFile = os.path.join(localPath, fileDict["name"])
        urlParts["url"] = fileDict["url"]
        urlParts["auid"] = auid
        urlParts["frame"] = "content"
        url = "%s?%s" % (urlBase, urllib.urlencode(urlParts))
        if not os.path.exists(localPath):
            os.makedirs(localPath)
        #print "Getting file %s from location %s" % (localFile, url)
        retrieveBigURL(url, localFile, name, password)
        
def addMD5Manifest(bagPath, fileDictList):
    """
    Take a filled bag, and generate an md5 manifest for it
    """
    MD5ManifestPath = os.path.join(bagPath, "manifest-md5.txt")
    MD5ManifestFile = open(MD5ManifestPath, "w")
    for fileDict in fileDictList:
        localPath = os.path.join(bagPath, "data", fileDict["path"], fileDict["name"])
        inFile = open(localPath, "r")
        chunk = inFile.read(2048)
        md5 = hashlib.md5()
        while chunk:
            md5.update(chunk)
            chunk = inFile.read(2048)
        hashString = md5.hexdigest()
        
        #the two spaces between hash and filename is critical
        MD5ManifestFile.write("%s  %s\n" % (hashString, os.path.join("data", fileDict["path"], fileDict["name"])))
    
    MD5ManifestFile.close()
            
        
    
        
            
def makeBagFromAUID(lockssURL, auid, name, password, newBagPath, fetchProxy, fill=False):
    """
    Try and automate the process
    """
    fileString = getFileString(lockssURL, auid, name, password)
    #print fileString
    hashString = getHashString(lockssURL, auid, name, password)
    fileDictList = makeFileDictList(fileString, hashString, True)
    
    makeBag(auid, fileDictList, newBagPath, fetchProxy, None, fill)
    
    if fill:
        fillBag(lockssURL, fileDictList, auid, newBagPath, name, password)
        addMD5Manifest(newBagPath, fileDictList)

def readConfig(configPath):
    """
    Attempt to eval a file defined at configPath and return the result dictionary.
    Check for certain needed values and raise exceptions if errors or missing values.
    """
    locals = {}
    
    execfile(configPath, {}, locals)
    checkKeys = [
        "username",
        "password",
        "lockss_url",
        "proxy_url",
    ]
    
    if not "config" in locals:
        raise Exception("Config file %s is not properly formatted" % configPath)
    
    config = locals["config"]
    
    for key in checkKeys:
        if not key in config or not config[key]:
            raise Exception("Missing required key '%s' from configuration file %s" %
                (key, configPath))
        
    return config

if __name__ == "__main__":
    
    usage = "usage: %prog [options] <AU Identifier> <Output Directory>"
    
    parser = OptionParser(usage=usage)
    parser.add_option("-c", "--config", action="store", type="string",
        dest="config", help="Specify an alternate configuration file")
        
    parser.add_option("-f", "--fill", action="store_true",  dest="fill", 
        help="Create a filled bag, as opposed to a holey bag" )   
        
    (options, args) = parser.parse_args()
    
    if len(args) < 2:
        parser.print_help()
        sys.exit(1)
    
    if options.config:
        configPath = options.config
    else:
        configPath = os.path.join(os.environ["HOME"], ".lockssbagger")
        
    fillTheBag = False
    if options.fill:
        fillTheBag = True
    
    #read the config
    try:
        #perhaps readConfig should check for certain values being defined?
        config = readConfig(configPath)
    except Exception, e:
        sys.stderr.write("Error reading config file %s: %s\n" % (configPath, e))
        sys.exit(1)
        
    bagFullPath = os.path.abspath(args[1])
    
    if os.path.exists(bagFullPath):
        sys.stderr.write("There is already a directory at %s\n") % bagFullPath
        sys.exit(1)
        
    print "Constructing a new bag at %s from AUID %s" % (bagFullPath, args[0])
    
    makeBagFromAUID(config["lockss_url"], args[0], config["username"], config["password"], bagFullPath, config["proxy_url"], fillTheBag)
    
