#!/usr/bin/env python
''' script initializer - sets path 
$Author: $
$Revision: $
$Id: $''' 

import os
import sys

argv0 = sys.argv[0]
mypath = os.path.dirname( os.path.realpath(  argv0 ) )
sys.path.append(  os.path.join( mypath, './locksslib' ) )
sys.path.append(  os.path.join( mypath, './utils' ) )

from django.core.management import setup_environ

try:
    import settings     # assume to be in same dir 
except ImportError:
    sys.stderr.write("Error: Can't find the file 'settings.py' in the directory containing %r. \n" % __file__)
    sys.exit(1); 

setup_environ(settings)

#print sys.path
