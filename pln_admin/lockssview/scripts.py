#!/usr/bin/env python2.6
import os
import sys
from django.core.management import setup_environ

#print "PATH", "\nPATH ".join(sys.path); 

if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "lockssview.settings")

    import lockssview.settings   
    setup_environ(lockssview.settings)

    from scripts import dispatcher; 

    global script
    cmd = dispatcher.create_cmd()
    if (not cmd.options.dryrun):
        cmd.process()

if __name__ == "__test__":

    print sys.argv; 
