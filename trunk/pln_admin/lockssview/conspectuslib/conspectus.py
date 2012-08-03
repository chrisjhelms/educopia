#!/usr/bin/env python
'''Generate RC file from connspectus information 
$Author: $
$Revision: $
$Id: $''' 

import getopt, sys, json;
from datetime import date;
from urllib2 import *;
import traceback, codecs; 

class Conspectus:
    """
    provides access to Conspectus content via GET *.json 
    """

    
    def __init__(self, url, talk = True):
        # These values are created
        # when the class is instantiated.
        self.url = url
        self.verbose = talk;
        self.obj_cache = {};
        self.lst_cache =  {};

    def log(self, s):
        if (self.verbose):
            print "##Conspectus %s" % (s); 
    
    def get_url(self, theurl):
        self.log("GET %s.json" % theurl); 
        url_handle = urlopen("%s.json" % theurl);
        obj = json.loads(url_handle.read());
        url_handle.close(); 
        return obj; 
    
    def obj_url(self, kind, it):
        if (type(it) == int):
            return  "%s/%ss/%s" % (self.url, kind, it)
        else: 
            try: 
                return "%s/%ss/%d" % (self.url, kind, int(it))
            except:
                return  "%s/%ss/find/%s" % (self.url, kind, it)
    
    def get_obj(self, kind, it):
        if (not self.obj_cache.has_key(kind)): 
            self.obj_cache[kind] = {};
        if (not self.obj_cache[kind].has_key(it)): 
            self.obj_cache[kind][it] = None;
        if (self.obj_cache[kind][it]): 
            return self.obj_cache[kind][it];
        theurl = self.obj_url(kind, it)
        obj = self.get_url(theurl);
        obj['GET_URL'] = theurl;
        self.obj_cache[kind][obj['id']] = obj; 
        if (obj['id'] != it):
            self.obj_cache[kind][it] = obj; 
        return obj;
    
    def list_objs(self, kind):
        if (self.lst_cache.has_key(kind)): 
            return self.lst_cache[kind];
        theurl = "%s/%ss" % (self.url, kind)
        lst = self.get_url(theurl);
        self.lst_cache[kind] = lst; 
        return lst;
                 
if __name__ == "__main__":
    try:
        consp = Conspectus("http://conspectus.metaarchive.org")
        col = consp.get_obj("collection", 1); 
        cp = consp.list_objs("content_provider"); 
        col = consp.get_obj("collection", 1); 
        cp = consp.list_objs("content_provider"); 
        cp = consp.list_objs("plugins"); 
        
    except Exception as e:
        print "ERROR: %s" % str(e);
        traceback.print_exc(file=sys.stderr)        
