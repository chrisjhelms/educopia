from status.models import *
from django.contrib import admin

from models.m_auids          import MasterAuId
from models.m_auids          import LockssCacheAuId

from models.m_cache        import LockssCache

from models.m_austatus      import LockssCacheAuSummary
from models.m_austatus      import LockssCrawlStatus
from models.m_austatus      import UrlReport
from models.m_austatus      import Url

class LockssCacheAdmin(admin.ModelAdmin):
    list_display = ('domain', )   
admin.site.register(LockssCache, LockssCacheAdmin)

class LockssCacheAuIdAdmin(admin.ModelAdmin):
    list_display = ('plugin', 'extraParams', 'baseUrl', 'cache')
    list_filter = ['cache', 'plugin']        
admin.site.register( LockssCacheAuId, LockssCacheAuIdAdmin)

class UrlReportAdmin(admin.ModelAdmin):
    list_display = ('reportDate', 'auId')
    list_filter = ['version']
admin.site.register( UrlReport, UrlReportAdmin)

class LockssCacheAuSummaryAdmin(admin.ModelAdmin):
    list_display = ('diskUsageMB', 'agreement', 'status', 'auId')
    list_filter = ['status']
admin.site.register( LockssCacheAuSummary, LockssCacheAuSummaryAdmin)

class LockssCrawlStatusAdmin(admin.ModelAdmin):
    list_display = ('status', 'auId')
    list_filter = ['status']
admin.site.register(LockssCrawlStatus, LockssCrawlStatusAdmin)


"""
admin.site.register(LockssCacheCommPeer)
"""


    