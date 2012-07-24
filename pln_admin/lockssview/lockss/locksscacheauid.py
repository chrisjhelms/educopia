from django.db import models
from django.db.models import Q

import lockss_daemon; 
from lockss_util import LockssError, log

from lockss.lockssutil import  Action;
from lockss.locksscache import LockssCache;
from lockss.lockssmasterauid import MasterAuId;

class LockssCacheAuId(models.Model):
    masterAuId = models.ForeignKey(MasterAuId)
    cache = models.ForeignKey(LockssCache)
    auId = models.CharField(max_length=255, db_index=True)    # same as in masterAuId 
    
    def __init__(self, *args, **kwargs):
        super(LockssCacheAuId, self).__init__(*args, **kwargs)
        (self.masterAuId, created) = MasterAuId.objects.get_or_create(auId= self.auId)
        if (created): 
            self.save()
                
    def __unicode__(self):
        return "%s (%s)" % (self.cache, str(self.masterAuId))
    
    def delete(self, using=None):
        ausum = self.getlocksscacheausummary()
        if (ausum): 
            ausum.delete(using)
        lst = self.locksscrawlstatus_set.all()
        for e in lst:
            e.delete(using)
        lst = self.lockssurl_set.all()
        for e in lst:
            e.delete(using)
        self.__class__.objects.get(pk = self.pk) 
        super(self.__class__, self).delete(using) 
      

    def getLockssAu(self):
        ''' 
        same as masterAuid.getLockssAu but without DB query 
        '''
        if (not hasattr(self, 'lockssAu')): 
            self.lockssAu =  lockss_daemon.AU(self.auId)
        return self.lockssAu
    
    @staticmethod
    def get(auids, auidprefixes, cache):
        '''
        return set of LockssCacheAuId matching one of the given auid strings exactly \
        or beginning with one of the given auidprefixes (replacing "." chars with "|") 
        '''
        if (auids or auidprefixes): 
            qu = Q()
            for auid in auids:
                qu = qu | Q(auId = auid)
            for prefix in auidprefixes:
                qu = qu | Q(auId__startswith="|".join(prefix.split(".")))
            return LockssCacheAuId.objects.filter(qu, Q(cache=cache))
        return []; 
    
    def replication(self):  
        ''' return replication == number of known related LockssCacheAuIds; include self in count '''
        return self.masterAuId.replication()
    
    '''
    return None or lockssausummary 
    '''
    def getlocksscacheausummary(self):
        try: 
            lau =  self.locksscacheausummary
            return lau
        except Exception as e:
            log.debug(str(e));
            return None
        
    '''
    create LockssCachAuIds based on keystrings in given array and attach to given cache 
    '''
    @staticmethod
    def load_keystrings(keystrings, cache):
        for auid in keystrings:
            if (not LockssCacheAuId.objects.filter(auId=auid, cache=cache).exists()): 
                try: 
                    LockssCacheAuId(auId=auid, cache=cache).save()
                except LockssError as err:
                    log.warn("could not create: %s" % (err))

    '''
    load data from given cache 
    '''
    @staticmethod
    def load(cache):
        log.info('Start %s: %s ...' % (Action.GETAUIDLIST, cache))
        success = True 
        ids = [];
        try:  
            ids = cache.ui.getListOfAuids()
            LockssCacheAuId.load_keystrings(ids, cache)
        except LockssError as inst:
            log.error("could not load auidlist from %s (%s)" % (cache, str(inst)))
            success = False
        log.info('Stop %s: %s  Success = %s ...' % (Action.GETAUIDLIST, cache, success))
        return success
    
       
    @staticmethod
    def printcsv(f, auids, sep):
        if (not auids): 
            log.info('NOOP %s: No auids for %s' % (Action.PRTAUIDLIST, f.name) )
            return
        log.info('Start %s: File %s ...' % (Action.PRTAUIDLIST, f.name))
        f.write(LockssCacheAuId.csvheader(True, sep) + "\n")
        for auid in auids:
            f.write(auid.csv(True, sep) + "\n")
        log.info('Stop %s: File %s ...' % (Action.PRTAUIDLIST, f.name))
        
    @staticmethod
    def csvheader(withauid, sep):
        csv = sep.join(("cache", "plugin", "baseUrl", "extraParams"))
        if (withauid):
            csv = sep.join((csv, "auId")) 
        return csv
        
    def csv(self, withauid, sep):
        csv = sep.join((str(self.cache), self.masterAuId.plugin, self.masterAuId.baseUrl, self.masterAuId.extraParams))
        if (withauid):
            csv = sep.join((csv, self.auId)) 
        return csv
