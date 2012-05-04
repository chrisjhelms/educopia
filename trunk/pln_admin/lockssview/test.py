from time import time ;

import scriptinit

import sys

from status.models import *;
from django.db.models import Q
from django.core.exceptions import ObjectDoesNotExist

from lockss_util import log

from status.models import *; 


if (True): 
   caches = {};
   for cn in ["unt", "rice-cap"]: 
       caches[cn] = LockssCache.objects.get(name=cn)
       caches[cn].username = "madebug" 
       caches[cn].password = "dIstrIbuteD" 
       #caches[cn].reconnect(0, 10); 
   print caches; 

   cache = caches["unt"]; 
   cauids = cache.locksscacheauid_set.all() 
   cauid = cauids[0]
   mauid = cauid.masterAuId
   print "cauid=", cauid

url = Url.objects.all()[0]
print "url=%s" % url 
rpt = url.urlReport
print "rpt=%s" % rpt 
cauid=rpt.auId; 
print "cauid=", cauid
cache=cauid.cache; 
print "cache=", cache
mauid=cauid.masterAuId; 
print "mauid=", mauid

#cache.getListOfAuids()
#cache.ui.getAuV3Voters(cauid); 
print "-------------------------\n\n";


cache = caches['unt']; 
cache.username = "madebug" 
cache.password = "dIstrIbuteD" 
cache.reconnect(0, 10); 

print "\n\n\n"; 
au = lockss_daemon.AU( 'edu|folger|shakespeare&base_url~http%3A%2F%2Fmetaarchive%2Efolger%2Eedu%2FCollectionImages%2FImageMasters&from~15701' );

url = 'http://metaarchive.folger.edu/CollectionImages/ImageMasters/Masters-015701-016000/manifest-15701-15750.html';
replicated_url = 'http://metaarchive.folger.edu/CollectionImages/ImageMasters/manifest.html'
url_image = 'http://metaarchive.folger.edu/CollectionImages/ImageMasters/Masters-015701-016000/015726.tif'; 
for url in [ url, url_image, replicated_url]:
    print "ulr=%s" % url;
    c = cache.ui.getUrlContent(url, au); 
    print "-----------------------"

au = lockss_daemon.AU( 'edu|bc|DigiToolPlugin&base_url~http%3A%2F%2Fdcollections%2Ebc%2Eedu&volume_name~brooker07');
url = 'http://dcollections.bc.edu/lockss/brooker07/161911/161911_manifest.html'
c = cache.ui.getUrlContent(url, au); 

if (False):
    print "\n\n\n"; 
    url= 'http://content.lib.auburn.edu/autest/image/101.jpg'; 
    c = cache.ui.getUrlContent(url); 
    au = lockss_daemon.AU( 'edu|auburn|contentdm&base_url~http%3A%2F%2Fcontent%2Elib%2Eauburn%2Eedu%2F&volume_name~autest');
    c = cache.ui.getUrlContent(url, au); 
