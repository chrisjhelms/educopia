import inspect;
print "::",inspect.getfile(inspect.currentframe())

from django.contrib import admin
from lockssview import *; 

admin.site.register(LockssCache)
admin.site.register(MasterAuId)
admin.site.register(CacheCommPeer)


