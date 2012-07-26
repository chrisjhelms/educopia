#!/usr/bin/env python
'''Generate Report Template file from connspectus information 
$Author: $
$Revision: $
$Id: $''' 

import getopt, sys, json;
from datetime import datetime;
from urllib2 import *;
import commands, traceback;

class Script:
    """
    usage: genrc [OPTIONS]:
      generates rc files suitable for lockssview scripts 
      places generated files in directory hierarchy rooted at given root directory   
     
     -cCOLLECTION               collection id or name (blanks in name will not work) 
     --collection=COLLECTION   
      
     --help                     print help message 
     
     -uURL                      conspectus URL  
     --url=URL            
     
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
        self.collection =  None;
        for o, a in opts:
            if o == "-v":
                self.verbose = True
            elif o in ("-h", "--help"):
                self.usage(0)
                sys.exit(0); 
            elif o in ("-c", "--collection"):
                self.collection = a;
            elif o in ("-u", "--url"):
                self.url = a
            else:
                print "%s=%s unhandled" % (o,a) 
        if (args): 
            print "unused %s" % (args)
             
        if (not self.url): 
            print "Must give a conspectus url";
            self.usage(1);    
 
        if (not self.collection): 
            print "Must give a collection"; 
            self.usage(1); 
    
        
    def log(self, s):
        if (self.verbose):
            print "## %s %s" % (self.name, s); 
    
    def getobj(self, kind, oid):
        if (oid):
            try:
                url = "%s/%ss/%d" % (self.url, kind, int(oid))
                get_url = "%s.json" % url; 
            except:  
                url = "%s/%ss/find/%s" % (self.url, kind, oid)
                get_url = "%s/show.json" % url; 
            
        else: 
            # get list of kind instances  
            url = "%s/%ss" % (self.url, kind)
            get_url = "%s.json" % url
        self.log ("GET %s" % get_url); 
        url_handle = urlopen(get_url);
        obj = json.loads(url_handle.read());
        url_handle.close(); 
        return obj, url
    
        
    def doit(self, args):
        self.getargs(args)   
        
        c = self.collection; 
        col_f = sys.stdout;
        
        col, col_url = self.getobj("collection", c)
        ar, ar_url = self.getobj("archive", col['archive_id'])
        plug, plug_url = self.getobj("plugin", col['plugin_id'])
        cp, cp_url = self.getobj("content_provider", plug['content_provider_id'])
        
        col_f.write('Collection Ingest Report'); 
        col_f.write('Date: %s' %  datetime.today().strftime("%a %Y-%m-%d"));
        col_f.write('\n\n'); 
        
        col_f.write('---------------------------\n');
        col_f.write('Collection Info \n');
        col_f.write('---------------------------\n');
        col_f.write('Collection Title:   %s\n' % col['title']); 
        col_f.write('Collection Id:      %d\n' % col['id']); 
        col_f.write('Conspectus Url:     %s\n' % col_url); 

        col_f.write('\n'); 
        col_f.write('Archive:            %s\n' % ar['title']); 
        col_f.write('Content Provider:   %s\n' % cp['name']); 
        col_f.write('BaseUrl:            %s\n' % col['base_url']); 

        col_f.write('\n'); 
        col_f.write('Plugin:             %s\n' % plug['name']); 
        col_f.write("Plugin Urls:\n"); 
        col_f.write("     Conspectus Url\t%s\n" % plug_url); 
        
        for mode in ['test', 'production']:
            col_f.write("     GoogleCode.%s\t" % mode);
            try: 
                url = plug['%s_plugin_url' %mode];
                urlopen(url);
                col_f.write("%s\n" % url);
                # HACK !! 
                # replace http://code.google.com/p/educopia/source/browse/ 
                # with http://educopia.googlecode.com/svn
                # so svn info is easy
                url = url.replace("http://code.google.com/p/educopia/source/browse", "http://educopia.googlecode.com/svn"); 
                lasts = commands.getoutput("svn info %s | fgrep Last " % url).split("\n")
                for l in lasts:
                    col_f.write("                \t\t%s\n" % l)
            except HTTPError:
                col_f.write("%s\n" % 'Undefined'); 
                    
        col_f.write('\n'); 

        col_f.write('---------------------------\n');
        col_f.write('Archival Units \n');
        col_f.write('---------------------------\n');
        for a in col['archival_units']: 
            au, au_url = self.getobj("archival_unit", a)
            extras = 0; 
            for p in au['params'].keys():
                if (p != 'base_url'): 
                    col_f.write("\t%s=%s" % (p, au['params'][p]))
                    extras = extras + 1;
            if (extras == 0): 
                col_f.write("Single AU Defined By Base_Url  ");
            col_f.write("\tstate=%s" % au['au_state_name']);
            if (au['off_line']): col_f.write('off_line'); 
            col_f.write("\n");
            
                    
        col_f.write("\n");

             
if __name__ == "__main__":
    try:
        s = Script().doit(sys.argv)
    except Exception as e:
        print "ERROR: %s" % str(e);
        traceback.print_exc(file=sys.stderr)        
