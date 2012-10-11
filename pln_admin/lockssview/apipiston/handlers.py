from piston.handler import BaseHandler, AnonymousBaseHandler
from piston.utils import rc, require_mime, require_extended
from piston.doc import generate_doc

from lockssview.models import LockssCache;

class LockssCacheHandler(BaseHandler):
    """
    Authenticated entrypoint for LockssCaches.
    """
    model = LockssCache
    anonymous = 'AnonymousLockssCacheHandler'
    fields = ('name', 'domain', 'port', 'network',  'locksscacheauids')

    @classmethod
    def locksscacheauids(cls, inst):
        return map( lambda o: o['auId'] , inst.locksscacheauid_set.values('auId'))

    def read(self, request, name=None):
        """
        Returns a cache, if `name` is given,
        otherwise all the caches.
        
        Parameters:
         - `name`: The name of the LockssCache to retrieve.
        """
        base = LockssCache.objects
        
        if name:
            return base.get(name=name) 
        else:
            return base.all()
        
class AnonymousLockssCacheHandler(LockssCacheHandler, AnonymousBaseHandler):
    """
    Anonymous entrypoint for LockssCaches.
    """

class NetworkHandler(BaseHandler):
    """
    Authenticated entrypoint for networks.
    """
    anonymous = 'AnonymousNetworkHandler'

    def read(self, request, name=None):
        """
        Returns a cache, if `name` is given,
        otherwise all the caches.
        
        Parameters:
         - `name`: The name of the Network to retrieve.
        """
        if name:
            fields = ('name' )
            base = LockssCache.objects
            return base.filter(network=name) 
        else:
            st = set(map ( lambda o: o['network'], LockssCache.objects.values('network')));
            return list(st)

class AnonymousNetworkHandler(LockssCacheHandler, AnonymousBaseHandler):
    """
    Anonymous entrypoint for network.
    """



doc = generate_doc(LockssCacheHandler)

print doc.name # -> 'LockssCacheHandler'
print doc.resource_uri_template # -> '/api/post/{id}'

methods = doc.get_methods()

for method in methods:
   print method.name # -> 'read'
   print method.signature # -> 'read(post_slug=<optional>)'

   sig = ''

   for argn, argdef in method.iter_args():
      sig += argn

      if argdef:
         sig += "=%s" % argdef

      sig += ', '

   sig = sig.rstrip(",")

   print sig # -> 'read(repo_slug=None)'
