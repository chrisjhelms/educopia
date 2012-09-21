#!/usr/bin/env python
'''Cache Status Reporter

based on polorus.py 
$Author: $
$Revision: $
$Id: $''' 

import inspect
#print ">> ", inspect.getfile(inspect.currentframe())

import types, sys, string;

from caches import Caches; 
from cleandb import Cleandb
from cachestatus import Cachestatus; 
from crawlstarter import Crawlstarter; 
from watchcrawls import Watchcrawls;
from report_auprofile import Report_auprofile; 
from report_urlprofile import Report_urlprofile; 
from report_aubestcopy import Report_aubestcopy; 


def usage():
    print >> sys.stderr, "available commands: "
    for k in sorted(globals().keys()): 
        if string.ascii_uppercase.find(k[0]) != -1: 
            print >> sys.stderr, "\t%s" % k.lower(); 
    sys.exit(1); 
    
def create_cmd():
    if (len(sys.argv) > 1):
        cmd = sys.argv[1].capitalize();
        globs = globals(); 
        if (globs.has_key(cmd)): 
            script = globals()[cmd];
            if isinstance(script, types.ClassType): 
                sys.argv = sys.argv[1:];
                print "run %s" % (" ".join(sys.argv))
                return script(cmd.lower());
    usage(); 
    
