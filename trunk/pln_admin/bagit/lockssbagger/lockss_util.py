import urlparse
import urllib
import httplib2
import BeautifulSoup as BS
import re
import os
import htmlentitydefs
import subprocess

wgetPath = "/usr/bin/wget"

def requestHash(lockssURL, auid, name, password, url="lockssau:", type="4"):
    """
    Go and get a hash file from the server
    """
    hashURL = urlparse.urljoin(lockssURL, "/HashCUS")
    httpObject = httplib2.Http(".cache") #do we need the cache thing?
    httpObject.add_credentials(name, password)
    headerDict = {}
    dataDict = {}
    
    headerDict["Content-Type"] = 'application/x-www-form-urlencoded'
    dataDict["auid"] = auid
    dataDict["url"] = url
    dataDict["action"] = "Hash"
    dataDict["hashtype"] = type
    
    urlData = urllib.urlencode(dataDict)
    
    response, content = httpObject.request(hashURL, "POST", body=urlData, headers=headerDict)
    
    return response, content
    
def getHashLink(html):
    """
    Given the output of a query to the HashCUS page, look for the download
    link in it (Go Go, Beautiful Soup!)
    """
    soup = BS.BeautifulSoup(html)
    anchors = soup.findAll('a')
    for anchor in anchors:
        if anchor.string == u"HashFile":
            if anchor.has_key('href'):
                return anchor['href']
    return ""

def retrieveURL(url, name, password, headerDict={}):
    """
    Get the contents of a given url
    """
    httpObject = httplib2.Http()
    httpObject.add_credentials(name, password)
    response, content = httpObject.request(url, "GET", headers=headerDict)
    return content

def retrieveBigURL(url, fileName, name="", password="", headerDict={}):
    """
    For retrieving large files, we're just going to call wget
    """
    authPart = []
    if name and password:
        authPart = [ "--http-user=%s" % name, "--http-password=%s" % password ]
    execList = [ wgetPath, "-q" ] + authPart + [ "-O", fileName, url ]
    subprocess.call(execList)    

    
def getHashString(lockssURL, auid, name, password):
    """
    Get the string representing a hash file
    """
    r,c = requestHash(lockssURL, auid, name, password)
    hashLink = getHashLink(c)
    if not hashLink:
        raise Exception, "No link found in returned html"
    cookies = r['set-cookie']
    headerDict = {}
    headerDict['Cookie'] = cookies
    hashURL = urlparse.urljoin(lockssURL, hashLink)
    print "hashURL = %s" % hashURL
    return retrieveURL(hashURL, name, password, headerDict)
    
def getFileString(lockssURL, auid, name, password):
    """
    Get the string representing the file listing of a given AU
    """
    requestDict = {}
    requestDict['auid'] = auid
    requestDict['type'] = 'files'
    requestString = urllib.urlencode(requestDict)
    requestURLBase = urlparse.urljoin(lockssURL, 'ListObjects')
    requestURL = "%s?%s" % (requestURLBase, requestString)
    c = retrieveURL(requestURL, name, password)
    return c

def unescapeEntities(text):
    """
    This function is taken from: http://effbot.org/zone/re-sub.htm#unescape-html
    """
    def fixup(m):
        text = m.group(0)
        if text[:2] == "&#":
            # character reference
            try:
                if text[:3] == "&#x":
                    return unichr(int(text[3:-1], 16))
                else:
                    return unichr(int(text[2:-1]))
            except ValueError:
                pass
        else:
            # named entity
            try:
                text = unichr(htmlentitydefs.name2codepoint[text[1:-1]])
            except KeyError:
                pass
        return text # leave as is
    return re.sub("&#?\w+;", fixup, text)

def makeFileDictList(fileListString, hashListString):
    #break fileList into a list of urls
    fileDictList = []
    fileLines = fileListString.splitlines()
    for fileLine in fileLines:
        #print fileLine
        fileLine = fileLine.strip()
        if not fileLine:
            continue
        if fileLine.startswith("#"):
            continue
        fileDict = {}
        lineParts = fileLine.split("\t", 3) #seems like tabs are used as delimiters
        urlObject = urlparse.urlparse(lineParts[0])
        fileDict["url"] = lineParts[0]
        pathPart,namePart = os.path.split(urlObject.path)
        pathPart = pathPart.strip(os.path.sep)
        fileDict["name"] = namePart
        fileDict["path"] = os.path.join(urlObject.hostname, pathPart)
        fileDict["hostname"] = urlObject.hostname
        fileDict["mimetype"] = lineParts[1]
        fileDict["size"] = int(lineParts[2])
        fileDictList.append(fileDict)
        
    #evaluate the first one to get the base URL
    #create a list of dictionaries
    #for each url in the url list, make a new dictionary and add it to the
        #dictionary list.  values in the dictionary should be full URL,
        #pathpart, filename
    
    hashLines = hashListString.splitlines()
    for hashLine in hashLines:
        hashLine = hashLine.strip()
        if not hashLine:
            continue
        if hashLine.startswith("#"):
            continue
        hashParts = hashLine.split(None, 2)
        hashDigest = hashParts[0]
        hashURL = hashParts[1]
        for fileDict in fileDictList:
            if fileDict['url'] == hashURL:
                fileDict['digest'] = hashDigest
                break
    
    return fileDictList

def getAUIDList(lockssURL, name, password):
    """
    Get a listing of all of the AUIDs a given cache is holding
    """
    baseURL = urlparse.urljoin(lockssURL, "DaemonStatus")
    requestDict = {}
    requestDict['table'] = "AuIds"
    requestString = urllib.urlencode(requestDict)
    requestURL = baseURL + "?" + requestString
    auidHTML = retrieveURL(requestURL, name, password)
    soup = BS.BeautifulSoup(auidHTML)
    tables = soup.findAll('table')
    auidTable = None
    auidList = []
    for table in tables:
        if table.tr and table.tr.th:
            if table.tr.th.string == "AU Ids":
                auidTable = table
                break
    if not auidTable:
        raise Exception, "Unable to parse AUID table from content returned at %s" % \
            requestURL
    trs = auidTable.findAll('tr')
    for tr in trs:
        if tr.td and tr.td.a:
            if tr.td.a["href"].startswith("/DaemonStatus?table=ArchivalUnitTable"):
                tds = tr.findAll('td')
                if len(tds) == 3:
                    auidList.append(unescapeEntities(tds[2].string))
                    
    return auidList
