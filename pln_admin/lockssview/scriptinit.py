#!/usr/bin/env python
''' script initializer - sets path 
$Author: $
$Revision: $
$Id: $''' 

import os
import sys

from django.core.management import setup_environ

try:
    import lockssview.settings     # assume to work with lockssview
except ImportError:
    sys.stderr.write("Error: Can't find the file 'settings.py' in the directory containing %r. \n" % __file__)
    sys.exit(1); 

setup_environ(lockssview.settings)

#print sys.path
