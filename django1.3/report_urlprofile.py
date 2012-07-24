#!/usr/bin/env python
'''Status Reporter
$Author: mmevenk $
$Revision: 3797 $
$Id: $'''

import scriptinit; 

import sys; 

from lockssscript import ReportScript; 
from lockss_daemon import LockssError;
from lockss_util import log

from status.models import *;
from django.db.models import Q

class ReportUrlProfile(ReportScript):
    '''
        if dryrun match auids and log.info them
        otherwise collect all known urls from selected archival units and report on them 
     
        if --urlminversion is given restrict to urls with at least the given number of versions 
    '''

    HEADEREXPLANATIONS =  {
                            "name" : "name of preserved URL",
                            "auId" : "LOCKSS Archival Unit id",
                            "plugin" : "archival unit plugin", 
                            "baseUrl" : "archival unit baseUrl", 
                            "extraParams" : "additional archival unit parameters",
                            "cache": "LOCKSS cache preserving archival unit",
                            'size' : "size of last URL version on LOCKSS cache",
                            "version" : "number of URL versions on LOCKSS cache", 
                            "urlRepl": "replication of URL on LOCKSS caches counted across archival units",
                            "urlKnownRepl": "number of archival units with available urlReport", 
                            "repl": "archival unit replication on LOCKSS caches",
                            "reportDate" : "urlReport date"
    };

    ALLHEADERS = sorted(HEADEREXPLANATIONS.keys())

    DEFAULTHEADERS = ["name", 
                "size",
                "version", 
                "cache", 
                "auId"
    ]; 
                

    MYCONFIGS = {
            'urlminversion':     1,
            'reportheaders':  ",".join(DEFAULTHEADERS)
            };


    def __init__(self, arg0): 
        ReportScript.__init__(self, arg0, '$Revision: 3738 $', ReportUrlProfile.MYCONFIGS)
        
    def _create_opt_parser(self):
        option_parser = ReportScript._create_opt_parser(self)

        option_parser.add_option('--urlminversion',
                                type='int',
                                help='minimum version [%default]')

        return option_parser
    
    def check_opts(self):
        ReportScript.check_opts(self, logopts=True)
        self.require_auids()

    def get_url_query(self, mauid, min_version, caches):    
        qu = Q(urlReport__auId__auId__exact=mauid.auId)
        if (min_version >1):
            qu = Q(qu, Q(version__gte=min_version))
        if (caches):
            cache_qu = None
            for c in caches:
                if (cache_qu):
                    cache_qu = cache_qu | Q(urlReport__auId__cache=c)
                else:
                    cache_qu = Q(urlReport__auId__cache=c)
            qu = Q(qu, cache_qu)
        return qu; 
        
    def process(self):
        log.info("---")
        log.info("Start Processing")

        if (self.options.dryrun):
            return
        if (self.options.explainheaders):
            print ReportScript.explainheaders(self);
            return;

        print "# COMMAND", self.options._COMMAND;
        print "# ";

        if (self.options.urlminversion > 1):
            print "# listing only urls with a version number greater equal than ", self.options.urlminversion
            print "# ";
        
        masterAuIds = self.collectMasterAuIdInstances()
        print self.report_preamble(); 

        headers = self.options.reportheaders; 
        fields = [];
        if ('reportDate' in headers):
            fields.append("urlReport")
        if ("auId" in headers or "cache" in headers ):
            fields.append("urlReport__auId")
        if ("cache" in headers ):
            fields.append("urlReport__auId__cache")
        relatedfields =  ",".join(fields);
        
        caches = None; 
        if (self.options.serverlist): 
            caches = self.options.cachelist;

        for mauid in masterAuIds:
            print "\n# AUID %s" % mauid.auId 
            mauidRepl = None; 
            urlKnownRepl = None; 
            
            qu =  self.get_url_query(mauid, self.options.urlminversion, caches); 
            urls = []; 
            if (fields): 
                urls = Url.objects.filter(qu).order_by('name').select_related(relatedfields); 
            else: 
                urls = Url.objects.filter(qu).order_by('name');
                
            if (urls): 
                print "\t".join(headers) 
                for u in urls: 
                    vals = [];
                    for h in headers: 
                        try: 
                            if (h == 'name'):
                                vals.append(u.name)
                            elif (h == 'size'):
                                vals.append(str(u.size))
                            elif (h == 'version'):
                                vals.append(str(u.version))
                            elif (h == 'auId'):
                                vals.append(u.urlReport.auId.auId)
                            elif (h == 'plugin'): 
                                vals.append(mauid.plugin)
                            elif (h == 'baseUrl'): 
                                vals.append(mauid.baseUrl)
                            elif (h == 'extraParams'): 
                                vals.append(mauid.extraParams)
                            elif (h == 'reportDate'):
                                vals.append(str(u.urlReport.reportDate))
                            elif (h == 'cache'): 
                                vals.append(str(u.urlReport.auId.cache));
                            elif (h == 'urlRepl'): 
                                repl = str(Url.objects.filter(name=u.name).count());
                                vals.append(str(repl))
                            elif (h == 'repl'):
                                if (not mauidRepl): 
                                    mauidRepl = str(mauid.replication()) 
                                vals.append(mauidRepl)
                            elif (h == 'urlKnownRepl'):
                                if (not urlKnownRepl):
                                    # number of cache aus for which we have a urlReport i
                                    qu = Q(auId__auId__exact=mauid.auId)
                                    urlKnownRepl  =  str(UrlReport.objects.filter(qu).count())
                                vals.append(urlKnownRepl)
                            else: 
                                raise LockssError("Unknown report header %s" % h)
                        except Exception as e:
                            vals.append("#Error url_id=%d %s" % (u.id, str(e)));
                    
                    print "\t".join(vals)
                       
        log.info("Stop Processing")


def __main():
    global script
    script = ReportUrlProfile(sys.argv[0])
    script.process()

    return 0

if __name__ == '__main__':
    __main()


