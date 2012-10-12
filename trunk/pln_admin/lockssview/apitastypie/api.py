# myapp/api.py
from tastypie.resources import ModelResource
from lockssview.models import *

class GetPostMeta:
    #list_allowed_methods = ['get', 'post']
    #detail_allowed_methods = ['get', 'post']
    allowed_methods = ['get', 'post']

class LockssCacheResource(ModelResource):
    class Meta(GetPostMeta):
        queryset = LockssCache.objects.all()
        resource_name = 'caches'
        
    def dehydrate(self, bundle):
        bundle.data['nauids'] = bundle.obj.locksscacheauid_set.count()
        return bundle
        
class MasterAuIdResource(ModelResource):
    class Meta(GetPostMeta):
        queryset = MasterAuId.objects.all()
        resource_name = 'master_auids'
    
    def dehydrate(self, bundle):
        bundle.data['repl'] = bundle.obj.locksscacheauid_set.count()
        return bundle
    
class LockssCacheAuIdResource(ModelResource):
    class Meta(GetPostMeta):
        queryset = LockssCacheAuId.objects.all()
        resource_name = 'caches_auids'

class LockssCacheAuSummaryResource(ModelResource):
    class Meta(GetPostMeta):
        queryset = LockssCacheAuSummary.objects.all()
        resource_name = 'cache_au_summaries'

class LockssCrawlStatusResource(ModelResource):
    class Meta(GetPostMeta):
        queryset = LockssCrawlStatus.objects.all()
        resource_name = 'au_crawl_status'

class UrlReportResource(ModelResource):
    class Meta(GetPostMeta):
        queryset = UrlReport.objects.all()
        resource_name = 'cache_au_url_report'

class CacheCommPeerResource(ModelResource):
    class Meta(GetPostMeta):
        queryset = CacheCommPeer.objects.all()
        resource_name = 'cache_comm_peer'

class RepositorySpaceResource(ModelResource):
    class Meta(GetPostMeta):
        queryset = RepositorySpace.objects.all()
        resource_name = 'cache_repos_space'


