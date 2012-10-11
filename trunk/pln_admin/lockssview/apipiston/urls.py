from django.conf.urls.defaults import *
from piston.resource import Resource, Emitter
from piston.authentication import HttpBasicAuthentication
from piston.doc import documentation_view

from apipiston.handlers import LockssCacheHandler, NetworkHandler;

auth = HttpBasicAuthentication(realm='Lockssview Piston API')

caches = Resource(handler=LockssCacheHandler, authentication=auth)
network = Resource(handler=NetworkHandler)

urlpatterns = patterns('',
    url(r'^caches/(?P<name>[a-zA-Z0-9-]+)/$', caches),
    url(r'^caches/(?P<name>[a-zA-Z0-9-]+)\.(?P<emitter_format>.+)$', caches),

    url(r'^network/$', network),
    url(r'^network\.(?P<emitter_format>.+)', network),
    url(r'^network/(?P<name>[a-zA-Z0-9-]+)/$', network),
    url(r'^network/(?P<name>[a-zA-Z0-9-]+)\.(?P<emitter_format>.+)$', network),

    # automated documentation
    url(r'^$', documentation_view),
)
