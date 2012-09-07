# NB: comparisons require access to the filesystem, so, won't run properly in dev.
# Generates a (locally viable) manifest page for LOCKSS crawl from an exported RDF file (i.e. DC Standard XML in CONTENTdm 6).

from lxml import etree
from StringIO import StringIO
import re, os, fnmatch


#rdfdir = '''C:\\Users\\amatthews.RWWL-MAIN\\Documents\\MetaArchive_dev\\20120817_monika\\'''
rdfdir = '''D:\\LOCKSS\\Assets\\metadata\\export\\'''

#tifdir = '''C:\\Users\\amatthews.RWWL-MAIN\\Documents\\LOCKSS\\Assets\\tif\\auc\\'''
tifdir = '''D:\LOCKSS\\Assets\\tif\\auc\\'''

# reverting; regularize
RDFNAME = 'export-auc-dc.t.xml'
# 'export_auc ..

""".."""

f = open(RDFNAME)
g = f.read()
parser = etree.XMLParser(encoding='iso-8859-1')

tree = etree.parse(StringIO(g), parser)

# sanity check
# print(etree.tostring(tree.getroot(), pretty_print=True))


root = tree.getroot()

# iterate metadata tree, for IDENTIS
identis = []
for element in root.iter("{http://purl.org/dc/elements/1.1/}identifier"):
    if element.text is not None:
        identis.append(element.text)

locksstargets = []
# walk the filesystem, for ORIGINALS
# http://stackoverflow.com/questions/2186525/
for dirpath, dirnames, filenames in os.walk(tifdir):
  for filename in fnmatch.filter(filenames, '*.tif'):
    for identi in identis:
      # here
      if os.path.splitext(identi)[0]+'.tif' == filename:
        locksstargets.append([[identi, filename], os.path.join(dirpath, filename)])

# print to html
manifesthead = '''
<html>
<head><title>Digital_Collection_of_Robert_W._Woodruff_Library_AUC/ LOCKSS Manifest Page</title></head>

<body>
<h2>Digital_Collection_of_Robert_W._Woodruff_Library_AUC</h2> 
<h3>
<img alt="MetaArchive logo" src="http://www.metaarchive.org/public/images/favicon.ico" />
Content preserved by <a href="http://www.metaarchive.org"> MetaArchive Network </a>
<br/>
<img alt="LOCKSS logo" src="http://www.lockss.org/favicon.ico" /> LOCKSS system has permission to collect, preserve, and serve this Archival Unit.
</h3>

<p>Collection Info:</p>

<ul>
<li>Conspectus Collection(s): <a href="http://www.metaarchive.org/conspectus/collections/find/HBCU_AUC-RWWL">Digital Collection of Robert W. Woodruff Library AUC</a> </li> 
<li>Institution: Atlanta University Center Robert W. Woodruff Library</li>
</ul>

<ul>
'''
manifesttail = '''
</ul>

</body>
</html>
'''

rdfinfo = '''<p><a href="'''+rdfdir+RDFNAME+'''">'''+RDFNAME+'''</a></p>'''

# for nomenclature, http://contentdm.org/help6/custom/customize2-1.asp # also per-collection help in {}config/configtool
# thus, e.g. http://hbcudigitallibrary.auctr.edu/cdm/manifest/collection/rwwl seeking index.php
# fi = open('index.php', 'w')
fi = open('index.g.php', 'w')
fi.write(manifesthead)
fi.write(rdfinfo)

for asset in locksstargets:
  fi.write('''<p><a href="'''+asset[1]+'''">'''+asset[0][1]+'''</a></p>''')

fi.write(manifesttail)
fi.close()



