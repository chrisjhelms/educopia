from django.http import HttpResponse
from django.http import HttpResponse
from django.template import Context, loader

def networks(request):
    obj_list = [ "production", "test", "incoming", "kaputt" ];    
    template = loader.get_template('networks.html')
    return HttpResponse(template.render(Context({'obj_list' : obj_list})))