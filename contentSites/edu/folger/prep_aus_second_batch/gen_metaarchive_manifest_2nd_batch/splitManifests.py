#!/usr/bin/python
import sys
import csv
import getopt

def main(cmd, argv):                         
    try:                                
        opts, args = getopt.getopt(argv, "hd", ["help", "debug"]) 
        for file in argv:
            doit(file)
    except getopt.GetoptError:           
        usage(cmd)                          
        sys.exit(2)                     

def usage(cmd):
    print  cmd, ": csv-file"; 

def doit(file):
   try: 
       reader = csv.reader(open(file, 'rb'), delimiter = '\t'); 
       naus = 1; 
       size = 4; 
       dir = 5; 
       try: 
           for row in reader: 
	      print "(cd ", row[dir], "; split -l ", row[size], " MANIFESTALL MANIFEST )"
       except csv.Error, e:
           sys.exit('file %s, line %d: %s' % (file, reader.line_num, e))
   except IOError, e:
       print e 
    
if __name__ == "__main__":
    main(sys.argv[0], sys.argv[1:])


