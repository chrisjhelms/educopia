from django.db import models
from django.db.models import Q

import time; 

import  lockss_daemon;
from lockss_util import log

# Create your models here.
class LockssCache(models.Model):
    class Meta: 
        app_label = "status"

    domain = models.CharField(max_length=64, unique=True)
    port = models.IntegerField()
    name = models.CharField(max_length=16, unique=True)
    network = models.CharField(max_length=16, unique=False)

    list_display = ( 'domain', 'name' )

    def __init__(self, *args, **kwargs):
        super(LockssCache, self).__init__(*args, **kwargs)
        self.username = None 
        self.password = None 
        self.ui = None 
    
    def delete(self, using=None):
        lst = self.locksscacheauid_set.all()
        for e in lst:
            e.delete(using)
        self.__class__.objects.get(pk = self.pk) 
        super(self.__class__, self).delete(using) 
    
    def reverse_dns(self): 
        parts = self.domain.split('.')
        parts.reverse(); 
        rdns = ".".join(parts) 
        return rdns;
    
    @staticmethod
    def connect(domain, port, username, password, timeout, sleep):
        cache = LockssCache(domain=domain, port = port) 
        if (not username or not password):
            raise RuntimeError, "Must give credentials to connect to %s" % cache
        
        ui = lockss_daemon.Client(cache.domain, cache.port, username, password)
        log.info("Start connecting to %s:%s as %s" % (domain, port, username))
        if not ui.waitForDaemonReady(timeout, sleep):
            log.error( "Failed connecting to %s" % cache) 
            return None 
        cache = LockssCache.objects.get_or_create(domain=domain, port = port)[0]
        cache.username = username 
        cache.password = password
        cache.ui = ui
        log.info("Success connecting to %s" % cache) 
        return cache
    
    def reconnect(self,sleep,timeout):
        ui = lockss_daemon.Client(self.domain, self.port, self.username, self.password)
        log.info("Start re-connecting to %s in %s sec" % (self, sleep))
        time.sleep(sleep);
        if not ui.waitForDaemonReady(timeout, sleep):
            log.error( "Failed re-connecting to %s" % self) 
            return False 
        self.ui = ui
        log.info("Success re-connecting to %s" % self)
        return True 
           
    @staticmethod
    def filter_all_domain(domainnames):
        ''' return caches with matching domain names ''' 
        if (domainnames): 
            qs = None
            for dns in domainnames: 
                if (qs) : 
                    qs = qs | Q(domain = dns) 
                else: 
                    qs = Q(domain = dns) 
            return LockssCache.objects.filter(qs); 
        else:
            return []; 
        
    def __unicode__(self):
        cache = "(" + self.name + ") " + self.domain + ":" + unicode(self.port) 
        return cache
    
    def csv(self, sep):
        return self.domain + ":" + unicode(self.port) 
    
    @staticmethod
    def printcsv(f):
        f.write("cache\n")
        for c in LockssCache.objects.all():
            f.write(c.csv() + "\n")

