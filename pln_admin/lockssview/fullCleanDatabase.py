#!/usr/bin/env python
# delete objects that do not pass vaildity check 

import scriptinit

import sys

from lockssscript import * 
from lockss_util import log
from status.models import * 
from django.core.exceptions import ValidationError

def cleanList(lst): 
   if lst:
      print "clean: %s" % str(lst[0].__class__) 
      for e in lst:
	try: 
		e.full_clean(); 
	except ValidationError as err:
		print "%s.%d.DELETE  %s" % (e.__class__.__name__, e.id, str(err)); 
		e.delete();


cleanList( UrlReport.objects.all())
cleanList( Url.objects.all())
cleanList( LockssCacheAuId.objects.all())
#cleanList( RepositorySpace.objects.all() );
cleanList( LockssCacheAuSummary.objects.all() );
cleanList( lst = LockssCrawlStatus.objects.all() );
cleanList( LockssUrl.objects.all()) 

