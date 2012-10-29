from django.contrib import admin
admin.autodiscover()

from django.conf.urls.defaults import patterns, url, include
from plnmonitor.settings import STATIC_URL; 

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    url(r'^$', 'django.views.static.serve', 
            { 'document_root': "" , 'path' : "index.html" } ),
    url(r'^content', 'django.views.static.serve', 
            { 'document_root': "" , 'path' : "content.html" } ),
    url(r'^static/(?P<path>.*)$', 'django.views.static.serve', {
            'document_root': STATIC_URL,
        }),  
    url(r'^api', include('apitastypie.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^admin/', include(admin.site.urls)),
)
