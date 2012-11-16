#!/usr/bin/env python
'''Status Reporter

based on cacheaustatus.py 
$Author: $
$Revision: $
$Id: $''' 

import sys, os;

from lockssview import *;
from lockss import log
from lockssscript import LockssScript; 

class Crawlwatcher(LockssScript):
    '''
    watch crawls of given archival units until each of the aus show that they have 
    been crawled on the given cache; 
    if an archival unit does not show any crawl info in the crawl status table,  
    wait until information becomes available (through a crawl starting 
    up and the finishing) 
    '''  

    MYCONFIGS = { 
            'dir':           None,
            'crawlsort':     'nErrorUrls',
            'crawlheaders':  'reportDate,startTime,cache,status,nBytesFetched,nMimeTypes,'
                               'nErrorUrls,nFetchedUrls,nNotModifiedUrls,nPendingUrls,'
                               'plugin,baseUrl,extraParams',
            'pause':           300
    }
    
    def __init__(self, argv0):
        LockssScript.__init__(self, argv0, '$Revision: $', Crawlwatcher.MYCONFIGS) 
        
    def _create_opt_parser(self):
        option_parser = LockssScript._create_opt_parser(self)

        option_parser.add_option('--pause',
                        type='int',
                        help="pause time in seconds between retrying active crawls [%default]")
        
        option_parser.add_option('-o', '--outputdir',
                        dest= 'dir', 
                        help='output directory [%default]')
        
        option_parser.add_option('--crawlsort',
                        type='choice',
                        choices=LockssCrawlStatus.SORTFIELDS,
                        help='sort field for ' + Action.PRTCRAWLSTATUS + ' action [%default]; available ' +  str(LockssCrawlStatus.SORTFIELDS))
        option_parser.add_option('--crawlheaders',
                        help='headers for ' + Action.PRTCRAWLSTATUS + ' [%default]; available headers ' +  
                        str(LockssCrawlStatus.PRTFIELDS) )
        
        return option_parser

    def check_opts(self):
        ''' 
        in addition to LockssScript.check_option: 
        checking that credentials 
        '''        
        
        LockssScript.check_opts(self)
        
        # options.action comes from commmand line args 
        # options.actionlist comes from config files  
        # action command line  args take precendence over args from config files 
        self.require_server()
        self.require_auids()
        self.require_credentials()

        if (len(self.options.serverlist) != 1): 
            self.option_parser.error("must give exactly one server");
        self.options.server = self.options.serverlist[0]; 
        
        if (not self.options.dir):
            self.options.dir = self.options.server[0]
        if (not os.path.exists(self.options.dir)):
            os.mkdir(self.options.dir)
        
        if (not self.options.pause > 0): 
            self.option_parser.error("pause must be greater than 0")

        self.options.crawlheaders = LockssCrawlStatus.strToPrtFields(self.options.crawlheaders) 
   
    def crawlstatus(self, auids):
        self.getcrawlstatus(auids, self.options.dir, True)   # retry until all of them have been retrieved 
        # now check which ones are still active 
        repeat = set() 
        for auid in auids: 
            if (LockssCrawlStatus.lastStatus(auid) != LockssCrawlStatus.DONE):
                log.info("Crawl not done %s" % auid) 
                repeat.add(auid) 
        return repeat 
    
    '''
    if dryrun collect matching auids and log.info them
    otherwise watch auids for active crawls until all are done
    finally print crawlstatus table about mosr recent crawls 
    '''
    def process(self):
        log.info("--- Start Processing") 
    
        options = self.options 

        server  = self.options.cachelist[0];
        self.cache = self.get_cache(server.domain, server.port, 
                                         True, options.username, 
                                         options.password)
        
        if (not self.options.dryrun):
            success = LockssCacheAuId.load(self.cache)
            if (not success):
                log.error('Exiting: could not load auids from cache %s' % (self.cache))
                raise RuntimeError, 'could not load auids from cache'
                              
        auids = self.collectAuIdInstances(self.cache)
        
        if (self.options.dryrun):
            return 
        
        repeat = auids
        while (repeat):             
            # do a first round until all auids are found to conform 
            # do not retry auids that are found to be ok  
            while (repeat):
                repeat = self.crawlstatus(repeat)
                if (repeat): 
                    self.sleep(options.pause)
                
            # time has expired, try on original auids to see 
            # whether they all still conforming 
            log.info("Retrying all auids to recheck") 
            repeat = self.crawlstatus(auids) 
            if (repeat):
                self.sleep(options.pause)
            
        log.info("No active crawls; printing info about most recent crawls") 
        f = open(options.dir + "/AuCrawlStatus.tsv", 'w')
        LockssCrawlStatus.printcsv(f, auids, options.crawlsort, 1, options.crawlheaders, "\t")
        f.close()
            
        log.info("--- Stop Processing") 
            
