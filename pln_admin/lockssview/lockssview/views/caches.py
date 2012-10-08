from django.shortcuts import render_to_response, get_object_or_404
from lockssview.models import LockssCache; 

def index(request):
    lst  = LockssCache.objects.all(); 
    return render_to_response('lockssview/caches/index.html', 
                              {'url' : '/lockssview/caches', 
                               'setname' : 'all', 'lst': lst})

def network(request,network):
    lst  = LockssCache.objects.filter(network=network); 
    return render_to_response('lockssview/caches/index.html', 
                              {'url' : '/lockssview/caches', 
                               'setname': network,'lst': lst})
    
def detail(request,obj_id):
    obj =  get_object_or_404(LockssCache, pk=obj_id); 
    return render_to_response('lockssview/caches/detail.html', {'obj': obj})
    