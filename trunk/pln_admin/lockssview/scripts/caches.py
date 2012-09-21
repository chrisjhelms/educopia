#!/usr/bin/env python
'''Cache Status Reporter

based on polorus.py 
$Author: $
$Revision: $
$Id: $''' 

import inspect
#print ">> ", inspect.getfile(inspect.currentframe())

import sys

from lockssscript import LockssScript 
from lockssview import LockssCache; 

class Caches(LockssScript):
    ''' list all known caches, without parameters print nickname and domainname '''
    
    CONFIGURATION_DEFAULTS = {
                'nickname': False,
                "dnsname":  False,  
                "nwname":  False,  
                "url": False,
                "network" : None
                }; 
                
    def __init__(self, argv0):
        LockssScript.__init__(self, argv0, '$Revision: $', Caches.CONFIGURATION_DEFAULTS) 
        
    def _create_opt_parser(self):
        option_parser =  LockssScript._create_parser(self, au_params=False, mayHaveServer=False, credentials=False) 
        option_parser.add_option('-N', '--Network',
                                  dest="network",
                                  help="print cache from give network only")
        option_parser.add_option('-n', '--nickname',
                                  action='store_true',
                                  help="print cache's nickname [%default]")
        option_parser.add_option('-D', '--dnsname',
                                  action='store_true',
                                  help="print cache's dnsname [%default]")
        option_parser.add_option('--nwname',
                                  action='store_true',
                                  help="print cache's network name [%default]")
        option_parser.add_option('-u', '--url',
                                  action='store_true',
                                  help="print cache's login url [%default]")
        return option_parser
    
    def process(self):
        if ( not self.options.nickname   and 
             not self.options.dnsname and 
             not self.options.url ) : 
            self.options.dnsname = True; 
            self.options.nickname = True; 
        if self.options.network:
            caches = LockssCache.objects.filter(network = self.options.network)
        else: 
            caches = LockssCache.objects.all()
        caches = caches.order_by('name'); 
        for c in caches: 
            if (self.options.nickname): 
                print c.name, "\t",
            if (self.options.dnsname): 
                print c.domain, "\t",
            if (self.options.nwname): 
                print c.network, "\t",
            if (self.options.url): 
                print "http://%s:%d" %  (c.domain, c.port), 
            print ""

def __main(): 
    global script
    script = Caches(sys.argv[0])
    if (not script.options.dryrun):
        script.process()
    return 0


    
if __name__ == '__main__':
    __main()
        
