import inspect; 
#print ">> ", inspect.getfile(inspect.currentframe())

from django.db import models
from django.db.models import Q
from django.core.exceptions import ObjectDoesNotExist;

from datetime import datetime;
import urllib2
import pytz  # 3rd party

from xml.parsers.expat import ExpatError;

from lockss import LockssError, log

from lockssview.models.Action import *;
from lockssview.models.CacheAuId import LockssCacheAuId; 
from lockssview import utils; 
'''
LockssCacheAuSummary corresponds to row in caches ArchivalUnitStatusTable for thei auid 
'''     
class LockssCacheAuSummary(models.Model):
    class Meta:
        app_label = 'lockssview'

    auId = models.OneToOneField(LockssCacheAuId, null=True)
    agreement = models.FloatField(blank=True, null=True)
    availableFromPublisher = models.BooleanField()
    contentSize = models.BigIntegerField()
    diskUsageMB = models.FloatField()
    repository = models.CharField(max_length=124)
    status = models.CharField(max_length=36)
    reportDate = models.DateTimeField()
    
    SORTFIELDS = [
                  "agreement",
                  "availableFromPublisher", 
                  "contentSize",
                  "diskUsageMB", 
                  "repository", 
                  "status",
                  "reportDate" ]
    
    PRTFIELDS = SORTFIELDS 
    PRTFIELDS.append("cache")
    PRTFIELDS.append("plugin")
    PRTFIELDS.append("baseUrl")
    PRTFIELDS.append("extraParams")
    PRTFIELDS.append("auId")

    def __unicode__(self):
        return "contentSize=%s, diskUsage=%s, agreement=%s rep=%s, status=%s, avail=%s reprt_date=%s %s" % (
                             self.contentSize,
                             self.diskUsageMB,
                             self.agreement,
                             self.repository,
                             self.status,
                             self.availableFromPublisher,
                             str(self.reportDate),
                             self.auId)

    def contentSizeMB(self):
        return self.contentSize / 1048576.0
    
    def agreementStr(self):
        if (self.agreement): 
            return str(self.agreement)
        else: 
            return ""
    
    @staticmethod
    def loadTryIt(ui, auId, doUrls):
        ''' 
        return (reportDate, urllist) 
        
        where urlllist contains all urls  iff doUrls == True 
        ''' 
        reportDate = datetime.utcnow().replace(tzinfo=pytz.UTC);
     
        summary, urllist = ui._getStatusTable('ArchivalUnitTable',
                                              auId.auId,
                                              unlimited_rows=doUrls)
        
        # work on summary 
        if (not summary):
            raise LockssError("ArchivalUnitTable returned empty info" % summary); 
  
        s = { 'auId' : auId }
        try: 
            s['reportDate'] = reportDate
            s['availableFromPublisher'] = 'Yes' == summary[ u'Available From Publisher'] 
            s['contentSize'] = summary[ u'Content Size'].replace(",", "") 
            s['diskUsageMB'] = summary[ u'Disk Usage (MB)'].replace(",", "") 
            s['repository'] = summary[ u'Repository']
            status = summary[ u'Status']
            s['status'] = status
            if (status.endswith('% Agreement')):
                s['agreement'] =  float(status[0:status.index('%')])
        except KeyError: 
            raise LockssError("ArchivalUnitTable returned faulty info for %s: %s" % (auId.auId, summary)); 
        
        lockssSummary = None;
        try:
            # check for existing au summary 
            lockssSummary = LockssCacheAuSummary.objects.get(auId = auId)
            lockssSummary.__dict__.update(s) 
        except: 
            lockssSummary = LockssCacheAuSummary.objects.create(**s)
        lockssSummary.save()
        
        return (reportDate, urllist);
        
    @staticmethod
    def __loadTry(ui, auId, datafresh): 
        '''
        deleting existing LockssCacheAuSummary 
	create new summary by reading status info from cache 
        '''   
        lockssSummary = None
        try:
            # check for existing au summary 
            lockssSummary = LockssCacheAuSummary.objects.get(auId = auId)
            if ((datetime.utcnow().replace(tzinfo=pytz.UTC) - lockssSummary.reportDate) < datafresh): 
                log.debug2("uptodate LockssCacheAuSummary available - not querying cache") 
                return lockssSummary    
        except: 
            pass; 
        
        log.info("get LockssCacheAuSummary %s" % auId);
        LockssCacheAuSummary.loadTryIt(ui, auId, False);
    

    @staticmethod
    def load(cache, auId, doUrls, expire, trials, sleep, timeout): 
        act = Action.GETAUSUMMARY
        if (doUrls): 
            act = act +  "," + Action.GETURLLIST
        log.info('Start %s: %s expire=%s ...' % (act, auId, str(expire)))
        success = False
        try: 
            for _ in  range(trials): 
                try: 
                    if (doUrls):
                        UrlReport.loadTry(cache.ui, auId, expire)
                    else:
                        LockssCacheAuSummary.__loadTry(cache.ui, auId, expire)
                    success = True
                    break
                except urllib2.HTTPError as inst:
                    cache.reconnect(sleep,timeout)
                except ExpatError: 
                    log.error("XML Parser error; could not %s %s" % (auId, act))
                    success = False; # try again 
            if (not success):                  
                log.error("exhausted trials for %s; could not load %s" % (auId, act))
        except LockssError as inst:
            log.warn("LockssException: %s" % inst)  # output is scanned for the ERROR string 
            log.warn("could not digest %s for %s" % (act, auId.auId)) 
        finally: 
            log.debug2('Stop %s: %s Success = %s ...' % (act, auId, success))
        return success
    
    @staticmethod 
    def strToPrtFields(s): 
        return utils.stringToArray(s, LockssCacheAuSummary.PRTFIELDS)
          
    @staticmethod
    def printcsv(f, auids, sort, hdrs, sep):
        if (not auids): 
            log.info('NOOP %s: No auids for %s' % (Action.PRTAUSUMMARY, f.name) )
            return
        cache  = auids[0].cache
        log.info('Start %s: Cache %s File %s ...' % (Action.PRTAUSUMMARY, cache, f.name))
        
        f.write(sep.join(hdrs) + "\n")
        # build query 
        qu = Q()
        for auid in auids:
            qu = qu | Q(auId = auid.id)
        sums = LockssCacheAuSummary.objects.filter(qu).order_by(sort)
        for sm in sums:
            f.write(sm.csv(hdrs, sep) + "\n")
        f.close()
        log.debug2('Stop %s: Cache %s File %s ...' % (Action.PRTAUSUMMARY, cache, f.name))

    
    def csv(self, hdrs, sep):
        vals = []
        for h in hdrs: 
            if (h == "agreement"): 
                vals.append(self.agreementStr())
            elif (h == "cache"): 
                vals.append(str(self.auId.cache))
            elif (h == "plugin"): 
                vals.append(self.auId.masterAuId.plugin)
            elif (h == "extraParams"): 
                vals.append(self.auId.masterAuId.extraParams)
            elif (h == "baseUrl"): 
                vals.append(self.auId.masterAuId.baseUrl)
            elif (h == "auId"): 
                vals.append(self.auId.auId)
            else:
                vals.append(str(self.__dict__[h]))
        return sep.join(vals) 

class UrlReport(models.Model):
    class Meta:
        app_label = 'lockssview'

    auId = models.OneToOneField(LockssCacheAuId, db_index=True)
    reportDate = models.DateTimeField()

    SORTFIELDS = ['name', 
                 'childCount',
                 'treeSize',
                 'size',
                 'version', 
                 'cache', 
                 'auid', 
                 'replication', 
                 'minversion',
                 'maxversion' ]

    PRTFIELDS = SORTFIELDS
        
    def __unicode__(self):
        return "%s: %s %s" % (self.auId.cache.name, self.reportDate, self.auId.auId) 
    
    @staticmethod 
    def strToPrtFields(s): 
        return utils.stringToArray(s, UrlReport.PRTFIELDS)

    @staticmethod
    def loadTry(ui, auId, datafresh): 
        '''
        create/update urlReport 
	    and associated related urls (deleting existing urls) 
        '''   
        urlReport = None
        reportDate = datetime.utcnow().replace(tzinfo=pytz.UTC)
        try:
            # check for existing au summary 
            urlReport = UrlReport.objects.get(auId = auId)
            if ((reportDate - urlReport.reportDate) < datafresh): 
                log.debug2("uptodate UrlReport available - not querying cache") 
                return urlReport
        except UrlReport.DoesNotExist:
            pass;
        
        log.info("get UrlReport %s" % auId) 
        (reportDate, urllist) = LockssCacheAuSummary.loadTryIt(ui, auId, True);
        if (not urllist):
            raise LockssError("%s on cache %s reports 0 urls" % (str(auId), auId.cache.name));

        if (not urlReport): 
            urlReport = UrlReport.objects.create(reportDate=reportDate, auId=auId);
        else:
            Url.objects.filter(urlReport=urlReport).delete()
        urlReport.reportDate = reportDate; 
        urlReport.save();
        print "urlReport ",  urlReport;
        try: 
            for url in urllist: 
                # work only on urls with real content 
                if (not url.has_key('NodeContentSize') or url['NodeContentSize'] == '-'): 
                    continue
                u = { 'urlReport' : urlReport }
                u['name'] = url[u'NodeName']
                u['childCount'] = url[u'NodeChildCount'] if url.has_key(u'NodeChildCount') else 0 
                u['treeSize'] =  url[u'NodeTreeSize'] if url.has_key(u'NodeTreeSize') else 0  
                u['size'] = url[u'NodeContentSize'] if url.has_key(u'NodeContentSize') else 0  
                u['version'] = url[u'NodeVersion'] if url.has_key(u'NodeVersion') else 0  
                if url.has_key(u'NodeVersion'):   
                    if (url[u'NodeVersion'] == '1' ): 
                        u['version'] = 1
                    else:
                        u['version'] =  url[u'NodeVersion']['value']
                lurl = Url.objects.create(**u)
                lurl.save()
                log.debug2("Url %s " % lurl.name)         
        except Exception as e: 
            urlReport.delete();  # deletes dependent urls 
            raise LockssError("Failed to read Url Info for %s %s\nException %s" % 
                                      (auId.cache.name, str(auId), str(e))) 
         
        
    @staticmethod
    def printcsv(folder, auids, orderby, hdrs, sep, minrev = 1):
        '''
        print url reports for all given auids including urls that have a 
        version at least as great as minrev, which defaults to 1
        '''       
        if (not auids): 
            log.info('NOOP %s: No auids to print to %s' % (Action.PRTURLLIST, folder) )
            return
        
        for auid in auids:
            urls = []
            try: 
                if (orderby == 'minversion' or orderby == 'replication'): 
                    urls = auid.urlreport.url_set.filter(version__gte=minrev).all()
                else: 
                    urls = auid.urlreport.url_set.filter(version__gte=minrev).order_by(orderby).all()
                ext = ".tsv"
                if (sep == ","): 
                    ext = ".csv"
                f = open(folder + "/" + auid.auId + ext, 'w')
                if (urls.count() == 0):
                    log.info("NOOP %s: file %s No Urls with version >= %s" % (Action.PRTURLLIST, f.name, minrev))
                log.info('Start %s: file %s version %s' % (Action.PRTURLLIST, f.name, minrev))
                try:
                    reportDate = auid.urlreport.reportDate 
                    f.write("ReportDate\t%s\nIncluding Urls with version >= %s\n\n" % (str(reportDate), minrev))
                    f.write(sep.join(hdrs) + "\n")
                    for url in urls:
                        f.write(url.csv(hdrs, sep) + "\n")
                    log.debug2('Stop %s: file %s version %s' % (Action.PRTURLLIST, f.name, minrev))
                    f.close()
                except IndexError:
                    log.info("NOOP %s: file %s No Urls at all" % (Action.PRTURLLIST, f.name))
            
            except ObjectDoesNotExist: 
                log.warn('Start %s: No UrlReport for %s at %s' % 
                         (Action.PRTURLLIST, auid, auid.cache.name))
                
            
    
class Url(models.Model):
    class Meta:
        app_label = 'lockssview'

    urlReport = models.ForeignKey(UrlReport, db_index=True)   
    name = models.TextField(max_length=1024)
    childCount = models.IntegerField()
    treeSize = models.BigIntegerField()
    size = models.BigIntegerField()
    version = models.IntegerField(blank=True,null=True)  
    
    def __init__(self, *args, **kwargs):
        super(Url, self).__init__(*args, **kwargs)
        if (self.childCount == '-'): 
            self.childCount = 0
        if (self.treeSize == '-'): 
            self.treeSize = 0
    
    def __unicode__(self):
        return "%s: %s" % (self.urlReport.auId.cache, self.name) 
    
    def compute(self): 
        try: 
            self.replication  # trigger exception if not set 
        except: 
            # compute vrsion and replication info across caches
            qu = Url.objects.filter(name = self.name, urlReport__auId__exact = self.urlReport.auId)
            self.replication = qu.count()
            self.maxversion = max((v['version'] for v in qu.values('version')))
            self.minversion = min((v['version'] for v in qu.values('version')))
            
    def csv(self, fields, sep):
        vals = []
        d = self.__dict__
        for f in fields:
            if (f == 'replication' or f == 'maxversion' or f == 'minversion'): 
                self.compute()
            if (f == 'cache'): 
                vals.append(self.urlReport.auId.cache.name)
            elif (f == 'auid'): 
                vals.append(self.urlReport.auId.auId)
            else:
                vals.append(str(d.get(f)))
        return sep.join(vals)

class LockssCrawlStatus(models.Model):
    class Meta:
        app_label = 'lockssview'

    auId = models.ForeignKey(LockssCacheAuId, db_index=True)

    ''' possible values for status
            Active
            Successful
            Error (catch-all for errors that failed to set a better status)
            Aborted (AU deleted/deactivated during crawl)
            Interrupted by crawl window
            Fetch error
            No permission from publisher
            Plugin error
            Repository error
            Interrupted by daemon exit
    '''
    status = models.TextField(max_length=32)
    
    type = models.TextField(max_length=32)
    startTime = models.DateTimeField()
    nBytesFetched = models.BigIntegerField()
    nExcludedUrls = models.IntegerField()
    nFetchedUrls = models.IntegerField()
    nNotModifiedUrls = models.IntegerField()
    nParsedUrls = models.IntegerField()
    nPendingUrls = models.IntegerField()
    nErrorUrls = models.IntegerField()
    nMimeTypes = models.IntegerField()
    reportDate = models.DateTimeField()
    duration = models.TextField(max_length=32) 
    
    
    def __unicode__(self):
        return "%s: %s" % (self.type, self.auId) 
    
    NOINFO = 0
    ACTIVE = 1
    DONE = 2
    
    SORTFIELDS = [
	'status',
	'type',
	'startTime', 
	'nBytesFetched', 
	'nExcludedUrls',
	'nFetchedUrls',
	'nNotModifiedUrls', 
    'nParsedUrls',
	'nPendingUrls',
	'nErrorUrls',
	'nMimeTypes',
    'reportDate'
    ]

    PRTFIELDS = SORTFIELDS 
    PRTFIELDS.append("duration")
    PRTFIELDS.append("cache")
    PRTFIELDS.append("plugin")
    PRTFIELDS.append("baseUrl")
    PRTFIELDS.append("extraParams")
    PRTFIELDS.append("auId")
    
    INTFIELDMAP = {
     'nExcludedUrls' : 'num_urls_excluded', 
     'nFetchedUrls' : 'num_urls_fetched', 
     'nNotModifiedUrls' : 'num_urls_not_modified',  
     'nParsedUrls' : 'num_urls_parsed',  
     'nPendingUrls' : 'num_urls_pending',
     'nErrorUrls' : 'num_urls_with_errors'  
    }
    
    
    @staticmethod
    def lastStatus(cacheauid):
        '''
        return status of last known crawl for cacheauid 
        ''' 
        try: 
            crawl = LockssCrawlStatus.recents(cacheauid, 1)[0]
            if (crawl.nPendingUrls > 0): 
                return LockssCrawlStatus.ACTIVE;
            else: 
                return LockssCrawlStatus.DONE;
        except IndexError:
            # there was no crawl info 
            return LockssCrawlStatus.NOINFO
         
    @staticmethod
    def recents(cacheauid, n):
        ''' 
        return list of the most recent n known crawls for given cacheauid
        '''
        return list(LockssCrawlStatus.objects.filter(auId=cacheauid.id).order_by('-startTime'))[0:n]
                            
                            
    @staticmethod
    def __loadTry(ui, auId): 
        '''
        delete existing LockssAuCrawlStatus and create new by reading status info from cache 
        '''
        log.debug("try %s" % (auId))
        st = { 'auId' : auId }
        status = ui.getCrawlStatus(auId.masterAuId.getLockssAu()) 
        reportDate = datetime.utcnow().replace(tzinfo=pytz.utc)

        if (not status): 
            log.debug2("No CrawlStatus Info for %s %s" % (auId.cache, auId.auId) )
        else: 
            for s in status: 
                # work on status info 
                if (not s):
                    raise LockssError("CrawlStatusTable returned empty info"); 
                try: 
                    st['reportDate'] = reportDate 
                    st['type'] = s['crawl_type']
                    st['startTime'] = datetime.strptime(s['start'], utils.UI_STRFTIME)
                    st['nBytesFetched'] = s['content_bytes_fetched'].replace(",", "") 
                    st['status'] = s['crawl_status']['value']
                    st['nMimeTypes'] = str(s['num_of_mime_types']['value'].replace(",", "")) 
                    st['duration'] = str(s['dur'])
                    for f in LockssCrawlStatus.INTFIELDMAP: 
                        val = s[LockssCrawlStatus.INTFIELDMAP[f]]
                        if (val.__class__ == unicode):
                            st[f] = int(val.replace(",", ""))
                        else: 
                            st[f] = str(val['value'].replace(",", "")) 
                except KeyError: 
                    raise LockssError("CrawlStatusTable returned faulty info for %s: %s" % (auId.auId, s)); 
    
                try:
                    # update existing crawl status  
                    crawl = LockssCrawlStatus.objects.get( auId = auId, startTime = st['startTime'])
                    crawl.__dict__.update(st) 
                    log.debug("LockssCrawlStatus UPD %s %s" % (crawl.startTime, str(crawl.auId)))
                except ObjectDoesNotExist:
                    # create new crawlstatus 
                    crawl = LockssCrawlStatus.objects.create(**st)
                    log.debug("LockssCrawlStatus NEW %s %s" % (crawl.startTime, str(crawl.auId)))
                crawl.save()
            
    '''
    query given cache for all CrawlStatusItems on given archival units and store results 
    in the database 
    '''
    @staticmethod
    def load(cache, auId, trials, sleep,timeout):
        success = False
        log.debug2('Start %s: %s ...' % (Action.GETCRAWLSTATUS, auId))
        try: 
            log.info('get %s: %s ...' % (Action.GETCRAWLSTATUS, auId))
            for i in  range(trials): 
                try: 
                    LockssCrawlStatus.__loadTry(cache.ui, auId)
                    success = True
                    break
                except urllib2.HTTPError as inst:
                    cache.reconnect(sleep,timeout)
                    log.error("exhausted trials for %s, could not load crawlstatus" % (auId))
        except LockssError as inst:
            log.warn("LockssException: %s" % inst)  # output is scanned for the ERROR string 
            log.warn("could not digest %s for %s" % (Action.GETCRAWLSTATUS, auId.auId)) 
        finally: 
            log.debug2('Stop %s: %s Success = %s ...' % (Action.GETCRAWLSTATUS, auId, success))
        return  success

    
    @staticmethod 
    def strToPrtFields(str): 
        return utils.stringToArray(str, LockssCrawlStatus.PRTFIELDS)
          
    '''
    print crawlstatus items for all given auids, 
    sorting crawlstatus first by auId, then startTime (descending) then by the given order field  
    limits printing of crawl staus items per auId to nlimit irf nlimit > 0 
    '''
    @staticmethod
    def printcsv(f, auids, sort, limit, hdrs, sep):
        if (not auids): 
            log.info('NOOP %s: No auids for %s' % (Action.PRTCRAWLSTATUS, f.name) )
            return
        cache  = auids[0].cache
        log.info('Start %s: Cache %s File %s ...' % (Action.PRTCRAWLSTATUS, cache, f.name))
        f.write(sep.join(hdrs) + "\n")
        if (limit > 0): 
            crawls = []
            for auid in auids:
                crawls = crawls + LockssCrawlStatus.recents(auid, limit)
            crawls = sorted(crawls, key=lambda crawl:crawl.__dict__.get(sort))
        else: 
            qu = Q()
            for auid in auids:
                qu = qu | Q(auId = auid.id)
            crawls = LockssCrawlStatus.objects.filter(qu).order_by(sort)
        
        for st in crawls:
            f.write(st.csv(hdrs,sep) + "\n")
        log.debug2('Stop %s: File %s ...' % (Action.PRTCRAWLSTATUS, f.name))
    
    def csv(self, fields, sep):
        vals = []
        d = self.__dict__
        for f in fields:
            mauid = self.auId.masterAuId.__dict__; 
            if (f in ["auId", "plugin", "baseUrl", "extraParams"]):
                vals.append(str(mauid.get(f)))
            elif (f == "cache"): 
                vals.append(str(self.auId.cache))
            else:
                vals.append(str(d.get(f)))
        return sep.join(vals)
