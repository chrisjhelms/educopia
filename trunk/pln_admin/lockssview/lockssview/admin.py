import inspect;
print "::",inspect.getfile(inspect.currentframe())

from django.contrib import admin
from lockssview import LockssCache; 

admin.site.register(LockssCache)


