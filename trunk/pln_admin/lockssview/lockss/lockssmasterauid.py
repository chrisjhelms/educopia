from django.db import models
from django.db.models import Q

import lockss_daemon; 
from lockss_util import LockssError, log

import re;

class MasterAuId(models.Model):
    auId = models.CharField(max_length=255, db_index=True)
    plugin = models.CharField(max_length=64)
    baseUrl = models.URLField(max_length=256)
    extraParams = models.CharField(max_length=128)

    def __init__(self, *args, **kwargs):
        super(MasterAuId, self).__init__(*args, **kwargs)
        if (not self.plugin): 
            self.lockssAu = self.getLockssAu()
            self.plugin = self.lockssAu.pluginId
            self.baseUrl = self.lockssAu.base_url
            vs = self.auId.split('&')
            vs.pop(0)
            extras = []
            for v in vs:
                if (not re.match("base_url", v)): 
                    extras.append(v)              
            self.extraParams = ",".join(extras) 
            
    def __unicode__(self):
        return "%s: %s %s" % (self.plugin, self.extraParams, self.baseUrl) 
   
    def getLockssAu(self):
        if (not hasattr(self, 'lockssAu')): 
            self.lockssAu =  lockss_daemon.AU(self.auId)
        return self.lockssAu
    
    def replication(self):  
        ''' return replication == number of known related LockssCacheAuIds '''
        return self.locksscacheauid_set.count()

    '''
    return set of MasterAuId matching one of the given auid strings exactly \
    or beginning with one of the given auidprefixes (replacing "." chars with "|") 
    '''
    @staticmethod
    def get(auids, auidprefixes):
        if (auids or auidprefixes): 
            qu = Q()
            for auid in auids:
                qu = qu | Q(auId = auid)
            for prefix in auidprefixes:
                qu = qu | Q(auId__startswith="|".join(prefix.split(".")))
            return MasterAuId.objects.filter(qu)
        return []; 
         
    '''
    create LockssAuIds based on keystrings in given array and attach to given cache 
    '''
    @staticmethod
    def load_keystrings(keystrings):
        for auid in keystrings:
            if (not MasterAuId.objects.filter(auId=auid).exists()): 
                try: 
                    MasterAuId(auId=auid).save()
                except LockssError as err:
                    log.warn("could not create: %s" % (err))   

