'''Status Reporter
$Author: $
$Revision: $
$Id: $''' 

from django.db.models import Avg, Min, Max

from lockssscript import * 
from lockss  import log
from lockssview import * 

class Report_aubestcopy(ReportScript):      
    '''
    if dryrun collect matching auids and log.info them
    otherwise collect stored data (do not update from LOCKSS caches) and print a report 
    '''
    
    def __init__(self, argv0):
                ReportScript.__init__(self, argv0, '$Revision: $')

    def _create_opt_parser(self):
        option_parser = LockssScript._create_parser(self, au_params=True, mayHaveServer=True, credentials=False)
        return option_parser
    
    def check_opts(self):
        LockssScript.check_opts(self, logopts=False)
        self.require_auids()
            
    def process(self):
        log.info("---") 
        log.info("Start Processing") 
    
        if (self.options.dryrun):
            return
        opts = self.options.__dict__
        print "# COMMAND", self.options._COMMAND; 
        for key in ['ausetname', 'auseturl']: 
            if (opts.has_key(key)): 
                print "#", key, opts.get(key); 
        print "# "; 
        
        caches = self.get_caches();
        print "# SERVER\t", "\n# SERVER\t".join([str(c) for c in caches]);
        print "# ";
                
        # TODO deal with serverlist - aka restrict to aus on given servers 
        fields = ["auid", "repl", "reportDate", "cache", "agree", 
                  "sizeMB", "diskMB", "repository", 
                  "#urls", "avg_version", "min_version", "max_version", 
                  "best_copy"]
        print "\t".join(fields); 
        for auid in self.options.auids: 
            # TODO restrict to servers in options.serverlist 
            auids = LockssCacheAuId.objects.filter(Q(auId=auid) ,self.get_Q_caches() )
            log.info("AUID: %s" % "\t".join([auid, "#matches=%d" % auids.count()]));

            profiles = []
            for au in auids: 
                prof = {
                        'auid' : auid,
                        'repl' : au.replication(),
                        'reportDate' : "",
                        'cache' : au.cache.name,
                        'agree' : "",
                        'repository' : "",
                        '#urls' : "",
                        'avg_version' : "",
                        'min_version' : "",
                        'max_version' : "", 
                        'sizeMB': "", 
                        'diskMB': "",
                        "best_copy" : False
                }
                lausum = LockssCacheAuSummary.objects.filter(auId = au); 
                if (not lausum.exists()):
                    log.warn("No AuSummary Info for " + str(au))
                else: 
                    lausum = lausum[0]; 
                    if (lausum.agreement != None) : prof['agree'] = lausum.agreement
                    prof['repository'] = lausum.repository
                    prof['sizeMB'] = lausum.contentSizeMB()
                    prof['diskMB'] = lausum.diskUsageMB
                    prof['reportDate'] = lausum.reportDate
                    
                    urlReport = UrlReport.objects.filter(auId = au);
                    
                    if (not urlReport.exists()): 
                        log.warn("No Url Info for " + str(au))
                        prof['nurls'] = 0
                    else: 
                        report = urlReport[0];
                        urls = report.url_set; 
                        
                        version_info = urls.aggregate(Avg('version'), Min('version'), Max('version'))
                        prof['avg_version'] =  version_info['version__avg'];
                        prof['min_version'] =  version_info['version__min'];
                        prof['max_version'] =  version_info['version__max'];
                profiles.append(prof) 
                    
            
            # find the au that has the max agreement and if there are multiple 
            # the one/one of the ones with the max avg_version number 
            # and designate as best_copy
            #
            # find max avg_version number 
            
            if (not [] == profiles):
                max_agree = max(v['agree'] for v in profiles) 
                # find all that have that max_agree value 
                candidates = []
                for prof in profiles:
                    if (prof['agree'] == max_agree): 
                        candidates.append(prof)
                max_version = max(v['avg_version'] for v in candidates) 
                for candidate in profiles:
                    if (candidate['avg_version'] == max_version): 
                        candidate['best_copy'] = 'True'
                        break
                assert(candidate)
                
                for prof in profiles: 
                    vals = []; 
                    for f in fields: 
                        v = prof[f]
                        if (v.__class__ == float):
                            vals.append("%.2f" % v)
                        else:
                            vals.append(str(v))
                    print "\t".join(vals) 
                for i in range(0,3): 
                    print "";
                           
        log.info("Stop Processing") 
 
        

