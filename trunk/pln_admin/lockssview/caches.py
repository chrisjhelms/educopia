#!/usr/bin/env python
'''Cache Status Reporter

based on polorus.py 
$Author: $
$Revision: $
$Id: $''' 

import scriptinit

import sys

from lockssscript import LockssScript 
from django.db import models
from status.models import LockssCache; 

class StatusScript(LockssScript):
    ''' list all known caches  '''
    
    def __init__(self, argv0):
        LockssScript.__init__(self, argv0, '$Revision: $', {}) 
        
    def _create_opt_parser(self):
        return LockssScript._create_parser(self, au_params=False, mayHaveServer=False, credentials=False) 
        
    def process(self):
        for c in LockssCache.objects.all(): 
            print c

def __main(): 
    global script
    script = StatusScript(sys.argv[0])
    if (not script.options.dryrun):
        script.process()
    return 0


    
if __name__ == '__main__':
    __main()
        
