from django.shortcuts import render_to_response
from lockssview.models import LockssCache; 

def index(request):
    lst  = LockssCache.objects.all(); 
    return render_to_response('generic/index.html', {'url' : 'caches', 'lst': lst})