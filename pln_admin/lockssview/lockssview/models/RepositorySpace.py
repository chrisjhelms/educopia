import inspect; 
print ">> ", inspect.getfile(inspect.currentframe())

from django.db import models
from django.core.exceptions import ObjectDoesNotExist
from django.db.models import Q

import urllib2;
from datetime import datetime;
import pytz;

from xml.parsers.expat import ExpatError;

from lockss import *

from lockssview.models.Action import Action;
from lockssview.models.Cache import LockssCache;

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
    class Meta:
        app_label = 'lockssview'

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
        log.debug2('Start %s: %s...' % (act, cache))
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
                
                reportDate = datetime.utcnow().replace(tzinfo=pytz.utc)
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
            log.debug2('Stop %s: %s Success = %s ...' % (act, cache, success))
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
        log.debug2('Start %s: Caches %s File %s ...' % (Action.PRTREPOSSPACE, clist, f.name))
        
        f.write(sep.join(RepositorySpace.HEADERS) + "\n")
        qu = Q()
        for cache in caches:
            qu = qu | Q(cache = cache)
        objs = RepositorySpace.objects.filter(qu).all(); 
        for o in objs:
            f.write(o.csv(sep) + "\n")
        f.close()
        log.debug2('Start %s: Caches %s File %s ...' % (Action.PRTREPOSSPACE, clist, f.name))
        
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
        reportDate = datetime.utcnow().replace(tzinfo=pytz.utc)
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
        log.debug2('Start %s:...' % (act))
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
            log.debug2('Stop %s: Success %s...' % (act, success))
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


