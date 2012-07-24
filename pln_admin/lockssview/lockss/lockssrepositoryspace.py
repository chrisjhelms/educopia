from django.db import models
from django.db.models import Q

import urllib2;
from datetime import datetime;

from xml.parsers.expat import ExpatError;

from lockss_util import LockssError, log
from utils import Utils

from lockss.lockssutil import Action, convertSizeString;
from lockss.locksscache import LockssCache; 
from lockss.locksscacheauid import LockssCacheAuId;

def getReposState(ui): 
    data = ui._getStatusTable('RepositorySpace');
    reposInfo = data[1];
    results = [];
    for ri in reposInfo: 
        vals = {};
        try: 
            vals['repo'] = ri['repo'];
            vals['sizeMB'] = convertSizeString(ri['size']); 
            vals['usedMB'] = convertSizeString(ri['used']); 
            results.append(vals);
        except KeyError:
            raise LockssError("received garbeled RepositorySpace info"); 
    return results; 
                        
class RepositorySpace(models.Model):
    cache = models.ForeignKey(LockssCache, db_index=True)
    sizeMB = models.FloatField(default=-1);
    usedMB = models.FloatField(default=-1);
    repo = models.CharField(max_length=32); 
    reportDate = models.DateTimeField()

    def __init__(self, *args, **kwargs):
        super(RepositorySpace, self).__init__(*args, **kwargs)
    
    def __unicode__(self):
        sp = "%s sizeMB:%.3f freeMB: %.3f" %(self.repo, self.sizeMB, self.usedMB); 
        return sp
    
    def freePercent(self): 
        ''' return free Percentage as int value '''
        return int((100 * (self.sizeMB - self.usedMB)) / self.sizeMB); 
                     
    @staticmethod
    def load(cache, trials, sleep, timeout): 
        act = Action.GETREPOSSPACE
        log.info('Start %s: %s...' % (act, cache))
        success = False
        try: 
            for _ in  range(trials): 
                try: 
                    results = getReposState(cache.ui); 
                except LockssError as inst:
                    log.warn("LockssException: %s" % inst)  # output is scanned for the ERROR string 
                    log.warn("could not digest %s %s" % (act, cache)) 
                    continue; # try again 
                except urllib2.HTTPError as inst:
                    cache.reconnect(sleep,timeout)
                    continue;
                
                reportDate = datetime.now() 
                vals = { 'cache': cache, 'reportDate' : reportDate}
                for r in results:
                    vals['repo'] = r['repo'];
                    vals['sizeMB'] = r['sizeMB']; 
                    vals['usedMB'] = r['usedMB']; 
                    # insert into db table 
                    qu = RepositorySpace.objects.filter(cache=cache, repo=vals["repo"])
                    if (qu.exists()): 
                        reposSpace = qu.get(); 
                        reposSpace.__dict__.update(vals)
                    else: 
                        reposSpace = RepositorySpace.objects.create(**vals)
                    reposSpace.save();
                success = True
                break;
            if (not success):                  
                log.error("exhausted trials for %s %s" % (act, cache))
        finally: 
            log.info('Stop %s: %s Success = %s ...' % (act, cache, success))
        return success

    HEADERS = ["cache", "repo", "sizeMB", "usedMB","free%"]; 
        
    def csv(self, sep):
        return sep.join([self.cache.name,self.repo, 
                          "%.3f" % self.sizeMB, 
                          "%.3f" % self.usedMB, 
                          str(self.freePercent())])
        
    @staticmethod
    def printcsv(f, caches, sep):
        clist =  ",".join(map(lambda x: x.name, caches))
        log.info('Start %s: Caches %s File %s ...' % (Action.PRTREPOSSPACE, clist, f.name))
        
        f.write(sep.join(RepositorySpace.HEADERS) + "\n")
        qu = Q()
        for cache in caches:
            qu = qu | Q(cache = cache)
        objs = RepositorySpace.objects.filter(qu).all(); 
        for o in objs:
            f.write(o.csv(sep) + "\n")
        f.close()
        log.info('Start %s: Caches %s File %s ...' % (Action.PRTREPOSSPACE, clist, f.name))
        
"""   
class LockssCacheCommPeer(models.Model): 
    cache = models.ForeignKey(LockssCache)
    remoteCache = models.ForeignKey(LockssCache)
    peer = models.CharField(max_length=28)
    fail = models.IntegerField()
    received = models.IntegerField()
    sent = models.IntegerField()
    originated = models.IntegerField()
    accepted = models.IntegerField()
    reportDate = models.DateTimeField()
    
    FIELDS = ['originated', 'fail', 'sent', 'received', 'accepted', 'reportDate', 'remoteCache', 'peer']
     
    def __unicode__(self):
        return "cache %s, peer=%s, fail=%d ,orig=%d, sent=%d, rcvd=%d reprt_date=%s %s" % (
                             str(self.cache),
                             self.peer,
                             self.fail,
                             self.originated,
                             self.sent,
                             self.received,
                             self.accepted,
                             str(self.reportDate))
    @staticmethod
    def __loadTry(ui, cache): 
        '''
        deleting existing LockssCacheCommPeer for given cache and create new ones 
        by reading SCommPeers table 
        '''    
        commPeers = None
        commPeers = ui._getStatusTable('SCommPeers')[1]
        
        # work on summary 
        reportDate = datetime.now() 
        s = { 'cache' : cache }
        s['reportDate'] =  reportDate
        
        for cp in commPeers: 
            s['peer'] =  cp[ u'Peer'] 
            s['fail'] =  cp[ u'Fail'] 
            s['originated'] =  cp[ u'Orig'] 
            s['sent'] =  cp[ u'Sent'] 
            s['received'] =  cp[ u'Rcvd'] 
            s['accepted'] =  cp[ u'Accept'] 
            ip = s['peer'][1:len(s['peer']-1)]
            
            s['remoteCache'] = remoteCache
            cacheComPeer = None
            try:
                # update existing 
                cacheComPeer = LockssCacheCommPeer.objects.get(peer = s['peer'], cache = cache)
                cacheComPeer.__dict__.update(s) 
            except ObjectDoesNotExist:
                # create new au summary 
                cacheComPeer = LockssCacheCommPeer.objects.create(**s)
            cacheComPeer.save()
    

    @staticmethod
    def load(cache, trials, sleep,timeout): 
        act = Action.GETCOMMPEERS
        log.info('Start %s:...' % (act))
        success = False
        try: 
            for i in  range(trials): 
                try: 
                    sum = LockssCacheCommPeer.__loadTry(cache.ui, cache)
                    success = True
                    break
                except urllib2.HTTPError as inst:
                    cache.reconnect(sleep,timeout)
            if (not success):                  
                log.error("exhausted trials; could not %s" % (act))
        except Exception as inst:
            log.error("could not digest comm peer status %s (%s)" % (str(inst), traceback.format_exc()))
        finally: 
            log.info('Stop %s: Success %s...' % (act, success))
        return success
    
    @staticmethod
    def csvheader(sep):
        return sep.join(LockssCacheCommPeer.FIELDS) + sep + "cache"
    
    def csv(self, sep):
        csv = []
        sd = self.__dict__
        for f in LockssCacheCommPeer.FIELDS: 
            csv.append(str(sd[f]))
        csv.append(str(self.cache))
        return sep.join(csv) 
    
    @staticmethod
    def printcsv(f, cache, sep='\t'):
        f.write(LockssCacheCommPeer.csvheader(sep) + "\n")
        for c in LockssCacheCommPeer.objects.filter(cache=cache):
            f.write(c.csv(sep) + "\n") 
"""


'''
LockssCacheAuSummary corresponds to row in caches ArchivalUnitStatusTable for thei auid 
'''     
class LockssCacheAuSummary(models.Model):
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

    def delete(self, using=None):
        lst = self.lockssurl_set.all()
        for e in lst:
            e.delete(using)
        self = self.__class__.objects.get(id=self.id)
        super(self.__class__, self).delete(using) 
            
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
        reportDate = datetime.now()         
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
            lockssSummary = LockssCacheAuSummary.objects.get(auId = auId)
            lockssSummary = LockssCacheAuSummary.objects.create(**s)
        lockssSummary.save()
        
        return (reportDate, urllist);
        
    @staticmethod
    def __loadTry(ui, auId, datafresh): 
        '''
        deleting existing LockssCacheAuSummary 
	create new summary by reading status info from cache 
        '''   
        # TODO make timedelta a parameter  
        lockssSummary = None
        try:
            # check for existing au summary 
            lockssSummary = LockssCacheAuSummary.objects.get(auId = auId)
            if (datetime.now() - lockssSummary.reportDate < datafresh): 
                log.info("uptodate LockssCacheAuSummary available - not querying cache") 
                return lockssSummary    
        except: 
            pass; 
        
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
                    success = False; # try again 
            if (not success):                  
                log.error("exhausted trials for %s; could not load %s" % (auId, act))
        except LockssError as inst:
            log.warn("LockssException: %s" % inst)  # output is scanned for the ERROR string 
            log.warn("could not digest %s for %s" % (act, auId.auId)) 
        finally: 
            log.info('Stop %s: %s Success = %s ...' % (act, auId, success))
        return success
    
    @staticmethod 
    def strToPrtFields(s): 
        return Utils.stringToArray(s, LockssCacheAuSummary.PRTFIELDS)
          
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
        log.info('Stop %s: Cache %s File %s ...' % (Action.PRTAUSUMMARY, cache, f.name))

    
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


