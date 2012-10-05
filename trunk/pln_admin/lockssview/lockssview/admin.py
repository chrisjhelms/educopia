import inspect;
print "::",inspect.getfile(inspect.currentframe())

from django.contrib import admin
from lockssview import *; 

admin.site.register(LockssCache)
admin.site.register(MasterAuId)
admin.site.register(LockssCacheAuId)
admin.site.register(LockssCrawlStatus)
admin.site.register(UrlReport)
admin.site.register(Url)
admin.site.register(CacheCommPeer)
admin.site.register(RepositorySpace)


