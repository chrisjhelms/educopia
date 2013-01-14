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
    serializer = Serializer(formats=['json', 'xml'])


class LockssCacheResource(ModelResource):
    #auIds = fields.ToManyField('lockssview.apitastypie.resources.LockssCacheAuIdResource', 'locksscacheauid'); 
    class Meta(GetPostMeta):
        queryset = LockssCache.objects.all()
        filtering = { 'name' : ('exact', 'startswith', ) ,
                      'network': ( 'exact', ), 
                      'domain' : ALL } 
        resource_name = 'caches'
        
    def dehydrate(self, bundle):
        bundle.data['nauIds'] = bundle.obj.locksscacheauid_set.count()
        return bundle

class MasterAuIdResource(ModelResource):
    cacheAuIds = fields.OneToManyField('apitastypie.resources.LockssCacheAuIdResource', 'locksscacheauid_set'); 

    class Meta(GetPostMeta):
        queryset = MasterAuId.objects.all()
        filtering = { #'auId' :    ( 'startswith', 'exact' ),   '|' => or 
                      #'plugin' :  ( 'startswith', 'exact' ),
                      'baseUrl' : ( 'startswith', 'exact' )  };
        resource_name = 'master_auids'
    
    def dehydrate(self, bundle):
        qu =  bundle.obj.locksscacheauid_set;
        #bundle.data['cacheAuIds'] = qu.all(); 
        bundle.data['repl'] = qu.count()
        return bundle
    
class LockssCacheAuIdResource(ModelResource):
    master_auId = fields.ForeignKey(MasterAuIdResource, 'masterAuId'); 
    cache = fields.ForeignKey(LockssCacheResource, 'cache'); 
    crawlStatus = fields.OneToManyField('apitastypie.resources.LockssCrawlStatusResource', 
                                        'locksscrawlstatus_set'); 
    cache_au_summary = fields.OneToOneField('apitastypie.resources.LockssCacheAuSummaryResource', 
                                       'locksscacheausummary'); 
    class Meta(GetPostMeta):
        queryset = LockssCacheAuId.objects.all()
        filtering = { 'cache_id' : ('exact', ), 
                      'auId' : ('exact', 'startswith', )} 
        resource_name = 'cache_auids'
        
    cache = fields.ToOneField('apitastypie.resources.LockssCache', 'cache'); 

class LockssCacheAuSummaryResource(ModelResource):
   auId = fields.ForeignKey(LockssCacheAuIdResource, 'auId'); 

   class Meta(GetPostMeta):
	queryset = LockssCacheAuSummary.objects.all()
        filtering = { 'agreement' : ('lt', 'lte', 'gt', 'gte' ),
                      'reportDate' : ( 'exact', 'lt', 'lte', 'gt', 'gte' ) 
                     } 
        resource_name = 'cache_au_summaries'

class LockssCrawlStatusResource(ModelResource):
    auId = fields.ForeignKey(LockssCacheAuIdResource, 'auId'); 

    class Meta(GetPostMeta):
        queryset = LockssCrawlStatus.objects.all()
        filtering = { 'status' : ('exact' ),
                      'reportDate' : ( 'exact', 'lt', 'lte', 'gt', 'gte' ) 
	};
        resource_name = 'au_crawl_status'

class UrlReportResource(ModelResource):
    auId = fields.ForeignKey(LockssCacheAuIdResource, 'auId'); 

    class Meta(GetPostMeta):
        queryset = UrlReport.objects.all()
        filtering = { 'reportDate' : ( 'exact', 'lt', 'lte', 'gt', 'gte' ) };
        resource_name = 'cache_au_url_report'

class CacheCommPeerResource(ModelResource):
    class Meta(GetPostMeta):
        queryset = CacheCommPeer.objects.all()
        filtering = { 'reportDate' : ( 'exact', 'lt', 'lte', 'gt', 'gte' ) };
        resource_name = 'cache_comm_peer'

class RepositorySpaceResource(ModelResource):
    class Meta(GetPostMeta):
        queryset = RepositorySpace.objects.all()
        filtering = { 'reportDate' : ( 'exact', 'lt', 'lte', 'gt', 'gte' ) };
        resource_name = 'cache_repos_space'


