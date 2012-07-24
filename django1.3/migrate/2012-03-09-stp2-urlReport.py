import os, sys; 

argv0 = sys.argv[0]
path = "%s/.." % os.path.dirname( os.path.realpath(  argv0 ) )
print path

path = os.path.realpath(path)
sys.path.append(  path )
sys.path.append(  os.path.join( path, './locksslib' ) )
sys.path.append(  os.path.join( path, './utils' ) )

print sys.path

import scriptinit
from lockssscript import *


ausums = LockssCacheAuSummary.objects.all() 
for ausum in ausums: 
    if ausum.lockssurl_set.count() == 0:
        continue 
    (rpt, created) = UrlReport.objects.get_or_create(auId=ausum.auId, 
                                                     defaults={'reportDate': ausum.reportDate})
    if (not created):
        if (ausum.reportDate < rpt.reportDate ): 
            print "skip %s %s" % (ausum.reportDate, ausum)
            continue;
    
    # delete all previously listed urls and replace by new url set
    Url.objects.filter(urlReport=rpt).delete()    
    rpt.reportDate = ausum.reportDate
    print "create/update UrlReport %s" % (rpt)
    for  lurl in ausum.lockssurl_set.all(): 
        u = Url.objects.create(urlReport=rpt, 
                               name=lurl.name, 
                               version=lurl.version, 
                               childCount=lurl.childCount, 
                               treeSize=lurl.treeSize, 
                               size=lurl.size )


