#!/usr/bin/env python
'''Crawl Starter 

$Author: $
$Revision: $
$Id: $''' 

import scriptinit

import sys

from lockssscript import LockssScript 
from lockss_util import log

class StatusScript(LockssScript):
    
    def __init__(self, argv0):
        LockssScript.__init__(self, argv0, '$Revision: $', {'max': 10}) 
    
    def _create_opt_parser(self):        
        option_parser = LockssScript._create_parser(self, au_params=True, mayHaveServer=True, credentials=True)
        option_parser.add_option('-m', '--max',
                        type='int',
                        help='maximum crawls that will be started')
        return option_parser
    
    def check_opts(self):
        LockssScript.check_opts(self)
        
        self.require_server()
        self.require_auids()
        if (self.options.max < 1):
            self.option_parser.error("max value (%d) must be greater equal 1" % self.options.max)
         
    def process(self):
        for server in self.options.cachelist: 
            self.cache = self.get_cache(server.domain, server.port,
                                         True, self.options.username, self.options.password)
            auids = self.collectAuIdInstances(self.cache)
            if (len(auids) > self.options.max):
                msg = "cowardly refusing to start %d crawls on %s" % (len(auids), self.cache) 
                raise RuntimeError, msg
                
            for auId in auids:
                log.info('Request Crawl: %s %s ' % (self.cache, auId))
                self.cache.ui.startCrawl(auId.getLockssAu())

            
def __main(): 
    global script
    
    script = StatusScript(sys.argv[0])
    if (not script.options.dryrun):
        script.process()
    
    return 0
                    
if __name__ == '__main__':
    __main()
        

