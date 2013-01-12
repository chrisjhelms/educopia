#!/usr/bin/env python
'''Status Reporter

based on polorus.py 
$Author$
$Revision$
$Id: $''' 

import os;
from datetime import timedelta; 

from lockss import log
from lockss import LockssError

from lockssscript import LockssScript 
from lockssview import *; 

ACTION = 'action'

class Cachestatus(LockssScript):
    """ 
    Applies actions such as retrieving status from LOCKSS caches or printing of certain status information about them.
    """
    
    MYCONFIGS = { 
            'dir':           ".",
            'action':        None, 
            'actionlist':    None,         # set in config files 
            
            'urlsort':       'name',
            'urlheaders':    'size,version,name',
            'urlminversion':  1,
            
            'ausummarysort': 'contentSize', 
            'ausummaryheaders':   'reportDate,contentSize,diskUsageMB,extraParams,plugin,baseUrl,cache,auId',
            
            'crawlsort':     'nErrorUrls',
            'crawlheaders':  'reportDate,startTime,cache,status,nBytesFetched,nMimeTypes,'
                               'nErrorUrls,nFetchedUrls,nNotModifiedUrls,nPendingUrls,'
                               'plugin,baseUrl,extraParams',
            'ncrawllimit':   1, 
            
            'expire':       7 * 24,   # 7 days 
            'noquits':       None
             }
    
    def __init__(self, argv0):
        LockssScript.__init__(self, argv0, '$Revision$', Cachestatus.MYCONFIGS) 
        
    def _create_opt_parser(self):
        option_parser = LockssScript._create_opt_parser(self)
        option_parser.add_option('-a', '--action',
                        action='append',
                        type='choice', 
                        choices=Action.values,
                        help='which action to take on arhival units, available ' + str(Action.values))
        option_parser.add_option('--ncrawllimit',
                        type='int',
                        help='limiting the number of printed crawl status per archival units in printcrawlstatus [%default]')
        
        option_parser.add_option('-x', '--expire',
                                type='int',
                                help='number of hours after which to expire data from LOCKSS caches  [%default]')
        
        option_parser.add_option('--noquit', 
                        action='store_true',
                        help = "repeat status datat requests for failed auids until all succeed" )
        option_parser.add_option('-o', '--outputdir',
                        dest= 'dir', 
                        help="Directory for output files [defaults to server's domain name]")
        
        option_parser.add_option('--crawlsort',
                        type='choice',
                        choices=LockssCrawlStatus.SORTFIELDS,
                        help='sort field for ' + Action.PRTCRAWLSTATUS + ' action [%default]; available ' +  
                        ",".join(sorted(LockssCrawlStatus.SORTFIELDS)))
        option_parser.add_option('--crawlheaders',
                        help='headers for ' + Action.PRTCRAWLSTATUS + ' [%default]; available headers: ' +  
                        ",".join(sorted(LockssCrawlStatus.PRTFIELDS)) )
        
        option_parser.add_option('--ausummarysort',
                        type='choice',
                        choices=LockssCacheAuSummary.SORTFIELDS,
                        help='sort field for ' + Action.PRTAUSUMMARY + ' action [%default]; available ' +  
                        ",".join(sorted(LockssCacheAuSummary.SORTFIELDS)))
        option_parser.add_option('--ausummaryheaders',
                        help='headers for ' + Action.PRTAUSUMMARY + ' [%default]; available headers: ' +  
                        ",".join(sorted(LockssCacheAuSummary.PRTFIELDS)) )
        
        option_parser.add_option('--urlsort',
                        type='choice',
                        choices=UrlReport.SORTFIELDS,
                        help='sort field for '  + Action.PRTURLLIST + ' action [%default]; available ' +  
                        ",".join(sorted(UrlReport.SORTFIELDS)))
        option_parser.add_option('--urlheaders',
                        help='headers for ' + Action.PRTURLLIST + ' [%default]; available headers: ' +  
                                         ",".join(sorted(UrlReport.PRTFIELDS)) )
        option_parser.add_option('--urlminversion',
                        help='include only urls with a version at least minversion when doing' + Action.PRTURLLIST + ' [%default] ' )
        return option_parser

    def check_opts(self):
        ''' 
        in addition to LockssScript.check_option: 
        checking that 
            at least on action is given 
            credentials are given with get actions 
        '''        
        LockssScript.check_opts(self)
        
        # options.action comes from commmand line args 
        # options.actionlist comes from config files  
        # action command line  args take precendence over args from config files 
        if (not self.options.action and self.options.actionlist):
            actionlist = self.options.actionlist.split('\n')
            self.options.action = []
            for a in actionlist:
                a = a.strip() 
                if (a):
                    if (a in Action.values): 
                        self.options.action.append(a)
                    else: 
                        self.option_parser.error( "Unknown action '%s'" % a)
        if (not self.options.action):
                self.option_parser.error( "Must give at least one get action; available actions %s" %  str(Action.values))

        if (Action.GETURLLIST in self.options.action):
            self.options.action.append(Action.GETAUSUMMARY)
        
        for a in self.options.action:
            if (a in Action.need_auids): 
                self.require_auids()
                break
        
        if (self.options.expire < 0): 
            self.option_parser.error("Expire option must be greater equal zero"); 
        self.options.expire = timedelta(hours=self.options.expire) 
        
        self.require_server()
        
        if (not os.path.exists(self.options.dir)):
            os.mkdir(self.options.dir)
        
        self.options.need_credentials = False 
        for a in self.options.action:
            if (a in Action.need_credentials): 
                self.options.need_credentials = True 
        
        if (self.options.need_credentials): 
                self.require_credentials()
 
        try:       
            self.options.urlheaders = UrlReport.strToPrtFields(self.options.urlheaders) 
        except RuntimeError as rt: 
            self.option_parser.error("%s available urlheader option: %s" % (rt, Url.PRTFIELDS))
        
        try: 
            self.options.ausummaryheaders = LockssCacheAuSummary.strToPrtFields(self.options.ausummaryheaders) 
        except RuntimeError as rt: 
            self.option_parser.error("%s available ausummmaryheader option: %s" % (rt, LockssCacheAuSummary.PRTFIELDS))
        
        try: 
            self.options.crawlheaders = LockssCrawlStatus.strToPrtFields(self.options.crawlheaders) 
        except RuntimeError as rt: 
            self.option_parser.error("%s, available crawlheaderoption: %s" % (rt, LockssCrawlStatus.PRTFIELDS))
        
    def log_opts(self):
        LockssScript.log_opts(self)
        if (self.options.action): 
            for a in self.options.action: 
                log.info("ACTION = %s", a)
    
    def process(self):
        log.debug2("---_Start Processing"); 
        for server in self.options.cachelist: 
            self.process_server(server)
        log.debug2("--- Stop Processing"); 
        
    def mkdir(self, action, server):
        dirname = "%s/%s" % (self.options.dir, server)
        if not os.path.exists(dirname):
            try: 
                os.makedirs(dirname,0777)
                log.info("created output directory %s" % dirname)
            except: 
                log.error("Could not create %s" % dirname)
                return None 
        else: 
                log.debug2("using output directory %s" % dirname)           
        return dirname 
    
    def open_file(self, server, action):
        f = None 
        dirname = self.mkdir(action, server)
        if (dirname): 
            f = open("%s/%s.tsv" % (dirname, action), 'w')
            if (not f): 
                log.error("Could not open %s/%s" % (dirname, action))
        return f
            
    def process_server(self, server):
        '''
        if dryrun collect matching auids and log.info them
        otherwise perform all requested actions 
        '''    
       
        log.info("------ Start Processing %s" % server) 
        options = self.options 
        try: 
            self.cache = self.get_cache(server.domain, server.port, 
                                         options.need_credentials, options.username, 
                                         options.password)
            
            
            if (not options.dryrun):
                if (Action.GETAUIDLIST in options.action): 
                    success = LockssCacheAuId.load(self.cache)
                    if (not success):
                        log.error('Exiting: could not load auids from cache %s' % (self.cache))
                        raise RuntimeError, 'could not load auids from cache'
            auids = self.collectAuIdInstances(self.cache)
            
            if (options.dryrun): 
                return
            
            if (Action.PRTAUIDLIST in options.action): 
                f = self.open_file(self.cache.name, Action.PRTAUIDLIST)  
                # TODO get all auids for server 
                if (f): 
                    LockssCacheAuId.printcsv(f, auids, "\t")
                    f.close()
            
            if (Action.GETREPOSSPACE in options.action):
                self.getreposspace()
        
            if (Action.PRTREPOSSPACE in options.action): 
                f = self.open_file(self.cache.name, Action.PRTREPOSSPACE)  
                if (f): 
                    RepositorySpace.printcsv(f, [ self.cache ], "\t")
                    f.close()
                    
            # actions below needs auids to operate on 
            if (not auids):
                log.info("no matching auids"); 
                return;
            
            doUrls = Action.GETURLLIST in options.action
            success = None
        
            if (Action.GETAUSUMMARY in options.action): 
                self.getausummaries(auids, options.dir, doUrls, options.expire, options.noquit)
                
            if (Action.PRTAUSUMMARY in options.action): 
                f = self.open_file(self.cache.name, Action.PRTAUSUMMARY)
                if (f): 
                    LockssCacheAuSummary.printcsv(f, auids, options.ausummarysort, options.ausummaryheaders, "\t")
                    f.close()
                
            if (Action.PRTURLLIST in options.action):
                dr = self.mkdir(options.action, self.cache.name)
                if (dr): 
                    UrlReport.printcsv("%s/%s" % (self.options.dir, server.name),  #dir, 
                                   auids, options.urlsort, options.urlheaders, '\t', options.urlminversion)
            
            if (Action.GETCRAWLSTATUS in options.action): 
                self.getcrawlstatus(auids, options.dir, options.noquit)
                    
            if (Action.PRTCRAWLSTATUS in options.action): 
                f = self.open_file(self.cache.name, Action.PRTCRAWLSTATUS)
                if (f): 
                    LockssCrawlStatus.printcsv(f, auids, options.crawlsort, options.ncrawllimit, options.crawlheaders, "\t")
                    f.close()
            
            if (Action.GETCOMMPEERS in options.action): 
                self.getcommpeers(options.dir, options.noquit)
        
            if (Action.PRTCOMMPEERS in options.action): 
                f = self.open_file(self.cache.name, Action.PRTCOMMPEERS)
                if (f): 
                    # TODO LockssCacheCommPeer.printcsv(f, self.cache)
                    f.close()
        except LockssError as e:
            log.error("EXCEPTION %s" % str(e))
        finally:         
            log.debug2("------ Stop Processing %s" % server) 
 
        
