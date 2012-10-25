#, STARTS myap/api.py
from tastypie import fields;
from tastypie.resources import ModelResource
from tastypie.authentication import BasicAuthentication
from tastypie.constants import ALL
from tastypie.serializers import Serializer
from lockssview.models import LockssCache, CacheCommPeer, RepositorySpace;
from lockssview.models import MasterAuId, LockssCacheAuId, LockssCacheAuSummary, LockssCrawlStatus, UrlReport;

class GetPostMeta:
    #list_allowed_methods = ['get', 'post']
    #detail_allowed_methods = ['get', 'post']
    allowed_methods = ['get', 'post']
    authentication = BasicAuthentication()
    serializer = Serializer(formats=['json', 'xml'])


class LockssCacheResource(ModelResource):
    class Meta(GetPostMeta):
        queryset = LockssCache.objects.all()
        filtering = { 'name' : ('exact', 'startswith', ) , 'network': ( 'exact', ), 'domain' : ALL } 
        resource_name = 'caches'
        
    def dehydrate(self, bundle):
        bundle.data['nauids'] = bundle.obj.locksscacheauid_set.count()
        return bundle
        
class MasterAuIdResource(ModelResource):
    class Meta(GetPostMeta):
        queryset = MasterAuId.objects.all()
        filtering = { 'auId' : ('startswith', ) };
        resource_name = 'master_auids'
    
    def dehydrate(self, bundle):
        bundle.data['repl'] = bundle.obj.locksscacheauid_set.count()
        return bundle
    
class LockssCacheAuIdResource(ModelResource):
    masterAuId = fields.ForeignKey(MasterAuIdResource, 'masterAuId'); 
    cache = fields.ForeignKey(LockssCacheResource, 'cache'); 

    class Meta(GetPostMeta):
        queryset = LockssCacheAuId.objects.all()
        filtering = { 'cache_id' : ('exact', ), 
                      'auId' : ('exact', 'startswith', )} 
        resource_name = 'cache_auids'

class LockssCacheAuSummaryResource(ModelResource):
    auId = fields.ForeignKey(LockssCacheAuIdResource, 'auId'); 

    class Meta(GetPostMeta):
        queryset = LockssCacheAuSummary.objects.all()
        filtering = { 'agreement' : ('lt', 'gt', )} 
        resource_name = 'cache_au_summaries'

class LockssCrawlStatusResource(ModelResource):
    auId = fields.ForeignKey(LockssCacheAuIdResource, 'auId'); 

    class Meta(GetPostMeta):
        queryset = LockssCrawlStatus.objects.all()
        resource_name = 'au_crawl_status'

class UrlReportResource(ModelResource):
    auId = fields.ForeignKey(LockssCacheAuIdResource, 'auId'); 

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


