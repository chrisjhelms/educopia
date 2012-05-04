from django.conf.urls.defaults import *

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

from django.contrib import databrowse
from status.models import LockssCache, LockssCacheAuId
from status.models import LockssCacheAuSummary, LockssUrl
from status.models import LockssCrawlStatus

#databrowse.site.register(LockssCache)
#databrowse.site.register(LockssCacheAuId)
#databrowse.site.register(LockssCacheAuSummary)
#databrowse.site.register(LockssUrl)
#databrowse.site.register(LockssCrawlStatus)


urlpatterns = patterns('',
    # Example:
    # (r'^lockssview/', include('lockssview.foo.urls')),
    # url(r'^data/(.*)', databrowse.site.root),
    
    # Uncomment the admin/doc line below to enable admin documentation:
    (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    #  enable the admin:
    (r'^admin/', include(admin.site.urls)),
)
