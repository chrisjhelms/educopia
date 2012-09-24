import inspect; 
#print ">> ", inspect.getfile(inspect.currentframe())

from django.db import models
from django.core.exceptions import ObjectDoesNotExist

import urllib2, re
import pytz;
import traceback; 
from datetime import datetime;

from lockss import log;
from lockssview.models.Action import  Action
from lockssview.models.Cache import LockssCache; 

class CacheCommPeer(models.Model): 
    class Meta:
        app_label = 'lockssview'

    cache = models.ForeignKey(LockssCache)
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
        deleting existing CacheCommPeer for given cache and create new ones 
        by reading SCommPeers table 
        '''    
        commPeers = ui._getStatusTable('SCommPeers')[1]
        
        # work on summary 
        reportDate = datetime.utcnow().replace(tzinfo=pytz.UTC);
        s = { 'cache' : cache }
        s['reportDate'] =  reportDate
        
        for cp in commPeers: 
            s['peer'] =  cp[ u'Peer'] 
            s['fail'] =  cp[ u'Fail'] 
            s['originated'] =  cp[ u'Orig'] 
            s['sent'] =  cp[ u'Sent'] 
            s['received'] =  cp[ u'Rcvd'] 
            s['accepted'] =  cp[ u'Accept'] 
            print s;
            
            m = re.search("\[.*?\]", s["peer"])
            ip =  m.group(0)
            print "ip %s" % ip; 
            cacheComPeer = None
            try:
                # update existing 
                cacheComPeer = CacheCommPeer.objects.get(peer = s['peer'], cache = cache)
                cacheComPeer.__dict__.update(s) 
            except ObjectDoesNotExist:
                # create new au summary 
                cacheComPeer = CacheCommPeer.objects.create(**s)
            cacheComPeer.save()
    

    @staticmethod
    def load(cache, trials, sleep,timeout): 
        act = Action.GETCOMMPEERS
        log.info('Start %s:...' % (act))
        success = False
        try: 
            for _ in  range(trials): 
                try: 
                    CacheCommPeer.__loadTry(cache.ui, cache)
                    success = True
                    break
                except urllib2.HTTPError as inst:
                    cache.reconnect(sleep,timeout)
            if (not success):                  
                log.error("exhausted trials; could not %s %s" % (act, cache))
        except Exception as inst:
            log.error("could not digest comm peer status %s (%s)" % (str(inst), traceback.format_exc()))
        finally: 
            log.debug('Stop %s: Success %s...' % (act, success))
        return success
    
    @staticmethod
    def csvheader(sep):
        return sep.join(CacheCommPeer.FIELDS) + sep + "cache"
    
    def csv(self, sep):
        csv = []
        sd = self.__dict__
        for f in CacheCommPeer.FIELDS: 
            csv.append(str(sd[f]))
        csv.append(str(self.cache))
        return sep.join(csv) 
    
    @staticmethod
    def printcsv(f, cache, sep='\t'):
        f.write(CacheCommPeer.csvheader(sep) + "\n")
        for c in CacheCommPeer.objects.filter(cache=cache):
            f.write(c.csv(sep) + "\n")
            
#print "<< ", inspect.getfile(inspect.currentframe())

