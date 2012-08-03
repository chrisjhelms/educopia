#!/usr/bin/env python
'''Generate RC file from connspectus information 
$Author: $
$Revision: $
$Id: $''' 

import getopt, sys, json;
from datetime import date;
from urllib2 import *;
import traceback, codecs; 
from conspectus import Conspectus;

class Script:
    """
    usage: genrc [OPTIONS]:
      generates rc files suitable for lockssview scripts 
      places generated files in directory hierarchy rooted at given root directory   
     
     -cCOLLECTION               collection id or name (blanks in name will not work) 
     --collection=COLLECTION   
      
     --help                     print help message 
     
     -pPROVIDER                 content provider defined in conspectus (give id or acronym)
     --provider=PROVIDER        give 'all' to do all content providers 
     
     -uURL                      conspectus URL  
     --url=URL            
     
     -r=dDIR                    root directory where generated rc files are maintained  
     --root=DIR
     
     -s=STATE                   include only archival units in given state 
     --state=STATE              optional arg; if not given take all aus with lockss_au_id
     
     -v                         verbose 
    """

    def usage(self, rc): 
        print Script.__doc__ 
        if (rc): 
            sys.exit(rc)
    
    
    def getargs(self, sysargs):
        try:
            opts, args = getopt.getopt(sysargs[1:], "c:hp:r:s:u:v", ["collection=", "help", "provider=", "root=", "state=", "url=", ])
        except getopt.GetoptError, err:
            # print help information and exit:
            print str(err) # will print something like "option -a not recognized"
            self.usage(2);
            
        self.argv = sysargs;  
        self.name = sysargs[0];  
        self.url = None
        self.verbose = False
        self.austate=None;
        self.root = ".";
        self.providers = []; 
        self.collections =  [];
        for o, a in opts:
            if o == "-v":
                self.verbose = True
            elif o in ("-h", "--help"):
                self.usage(0)
                sys.exit(0); 
            elif o in ("-p", "--provider"):
                self.providers = a;
            elif o in ("-c", "--collection"):
                self.collections.append(a); 
            elif o in ("-r", "--root"):
                self.root = a
            elif o in ("-s", "--state"):
                self.austate = a
            elif o in ("-u", "--url"):
                self.url = a
            else:
                print "%s=%s unhandled" % (o,a) 
        if (args): 
            print "unused %s" % (args)
             
        if (not self.url): 
            print "Must give a conspectus url";
            self.usage(1);    
 
        if (not self.providers and not self.collections): 
            print "Must give a content provider or collection"; 
            self.usage(1); 
        
        if (not self.root): 
            self.root = "/tmp"; 
            print "using roor = /tmp";
    
        
   
        
    def thedir(self, name):
        if not os.path.exists(name):
            os.makedirs(name); 
            self.log("created %s" % name);
        else: 
            self.log("using %s" % name);
        return name; 
    
    def rcfile(self, name):
        f = open(name, 'w')
        f.write("# date %s\n"% date.today()); 
        f.write("# %s\n"% " ".join(self.argv)); 
        f.write("#\n"); 
        f.write('[Status]\n'); 
        f.write("#\n"); 
        self.log( "rc file %s" % f.name); 
        return f; 
    
    def write_aus(self, fle, aus):
        fle.write("auidlist =\n");
        for a in aus: 
            au = self.conspectus.get_obj("archival_unit", a)
            if (self.austate and au['au_state_name'] != self.austate): 
                    au = None 
            if (au): 
                if (au['lockss_au_id']): 
                    fle.write("\t%s\n" % au['lockss_au_id'])
                else: 
                    fle.write("\t# unknown AUID %s\n" % au['GET_URL']) ;        
        fle.write("\n");
    
    def prt_collection(self, col_f, cp, col_url, col):
        if (cp): 
            col_f.write("# content provider:    id=%s (%s)\n" % (cp['id'], cp['acronym']));
        col_f.write("# collection:          id=%s %s\n" % (col['id'], col['title'].encode('utf-8')));
        col_f.write("# archival unit state: %s\n" % self.austate);
        col_f.write("# \n");

        col_f.write("ausetname=%s\n" % col['title']);
        col_f.write("auseturl=%s\n\n" % col_url);
        self.write_aus(col_f, col['archival_units']);
        return col['archival_units']

    
    def doit_collection(self, cp, cp_dir, c):
        col  = self.conspectus.get_obj("collection", c)
        col_url = col['GET_URL'];
        print "GEN %s\tid=%s %s" % (cp['acronym'], col['id'], col['title']); 
        col_dir = self.thedir( "%s/collection=%s" % (cp_dir , col['id']) )
        col_f = self.rcfile("%s/%s" % (col_dir, "lockssview.rc"))
        aus = self.prt_collection(col_f, cp, col_url, col)
        col_f.close();     
        return aus; 
        
    
    def doit_collection_list(self, cols):
        #print self.__dict__;
        col_f = self.rcfile("%s/%s" % (".", "lockssview.rc"))
        combined_aus = []; 
        for c in cols: 
            col = self.conspectus.get_obj("collection", c)
            col_url = col['GET_URL'];
            print "GEN id=%s %s" % (col['id'], col['title']); 
            col_f.write("\n\n####\n"); 
            aus = self.prt_collection(col_f, None, col_url, col)
            combined_aus.extend(aus)

        col_f.write("\n\n####\n"); 
        col_f.write("# combined auid list\n"); 
        self.write_aus(col_f, combined_aus);
        col_f.close();     
        
    def doit_provider(self, cp):
        #print self.__dict__;
        cp_dir = self.thedir( "%s/content_provider=%s" % (self.root , cp['id']) )
        cp_aus =[]; 
        print "GEN id=%s %s" % (cp['id'], cp['acronym']); 
        
        for c in cp['collections']: 
            aus = self.doit_collection(cp, cp_dir, c)
            cp_aus.extend(aus);
            
        cp_f = self.rcfile("%s/%s" % (cp_dir, "lockssview.rc"))
        cpname = cp['name'].encode('ascii', 'ignore')
        cp_f.write("# content provider:    id=%s (%s) %s\n" % (cp['id'], cp['acronym'], cpname));
        cp_f.write("# archival unit state: %s\n" % self.austate);
        cp_f.write("# \n");
        cp_f.write("ausetname=%s\n" % cp['acronym']);
        cp_url = self.conspectus.obj_url('content_provider', cp['acronym']);
        cp_f.write("auseturl=%s\n\n" % cp_url);
        self.write_aus(cp_f, cp_aus);
        cp_f.close(); 

    def doit(self, args):
        self.getargs(args)
        self.conspectus= Conspectus(self.url);
        
        if (self.providers): 
            if (self.providers == 'all'): 
                self.providers = self.conspectus.list_objs("content_provider")
            else: 
                cp = self.conspectus.get_obj("content_provider", self.providers)
                self.providers = [ cp ];
            for p in self.providers: 
                self.doit_provider(p)    

        if (self.collections): 
            self.doit_collection_list(self.collections)

    def log(self, s):
        if (self.verbose):
                print "## %s %s" % (self.name, s);    
             
if __name__ == "__main__":
    try:
        s = Script().doit(sys.argv)
    except Exception as e:
        print "ERROR: %s" % str(e);
        traceback.print_exc(file=sys.stderr)        
