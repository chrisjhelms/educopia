import inspect
print ">> ", inspect.getfile(inspect.currentframe())

from django.db import models

from lockssview  import utils;
from lockssview.models import *;
    
print "<< ", inspect.getfile(inspect.currentframe())