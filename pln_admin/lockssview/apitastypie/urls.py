from django.conf.urls.defaults import patterns, include;
from tastypie.api import Api;
from apitastypie.resources import *;


api = Api(api_name='')
api.register( LockssCacheResource() );
api.register( MasterAuIdResource() );
api.register( LockssCacheAuIdResource() );
api.register( LockssCacheAuSummaryResource() );
api.register( LockssCrawlStatusResource() );
api.register( UrlReportResource() );
api.register( CacheCommPeerResource() );
api.register( RepositorySpaceResource() );

urlpatterns = patterns('',
    # The normal jazz here...
    (r'^', include(api.urls)),
)
