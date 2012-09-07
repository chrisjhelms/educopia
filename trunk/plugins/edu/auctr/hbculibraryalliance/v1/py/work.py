# This is a pretty straightforward server-side Python script called from our plugin, 
#  which issues a webservice call against the item crawled by LOCKSS at base_url, and
#  creates (perhaps should simply be, issues via http) a webpage containing 
#   a) the retreived jpg metadata, and
#   b) the associated url of the tif.
#
# This is turn should simply be crawled by LOCKSS.
#
# Note that in HBCU Alliance, it is CONTENTdm 'identi' which is unique and sufficient to id.
# Note that in HBCU Alliance, later-added members evidently do not follow this prescription..
#
# CONTENTdm webservice calls are at 0.6 .
#
# Al Matthews, AUC RWWL, December 2011

import json, urllib2#, urllib

#TODO: identify unknowns and ensure completeness of the following collection list
collns = {
'asud':'asu',		# Alabama State University
'bchd':'ben',		# Bennett College for Women
'fupp':'ful',		# Fisk University Library
'gsbg':'gsu',		#	Grambling State University
'hamu':'vhi',		#	Hampton University Library
'rwwl':'auc',		#	Atlanta University Center
'lumo':'liu',		#	Lincoln University - Missouri
'ssld':'susla',		# Southern University at Shreveport
'lupa':'unknown',		# 
'mhmc':'unknown',		#
'mctb':'mlc',		# Miles College
'msmd':'msm',		# Morehouse School of Medicine
'nccu':'ncc',		# North Caroline Central University
'pcld':'pne',		# Paine College
'stad':'nra',		# St. Augustine's College
'schc':'sgw',		# South Carolina State University
'suam':'unknown',		# 
'tsul':'tsu',		# Tennessee State University
'txdc':'txi',		# Texas Southern University
'tuld':'tul',		# Tuskegee University Library
'udcw':'udc',		# University of the District of Columbia
'vsud':'vsu'		# Virginia State University
}

#TODO: there needs to be a paths adjustment here, whether via python or a forwarding call in DNS or whatever is still TBD

# testing only wsr = urllib2.urlopen('http://hbcudigitallibrary.auctr.edu:2012/dmwebservices/index.php?q=dmGetCollectionList/json')
wsr = urllib2.urlopen('http://hbcudigitallibrary.auctr.edu:2012/dmwebservices/index.php?q=dmGetItemInfo/rwwl/95/json')
wsrfo = wsr.read()
jso = json.loads(wsrfo)

jsodmrecord = jso['dmrecord']
jsoidenti = jso['identi']
jsofind = jso['find']

tifidenti = jsoidenti.rstrip('.jpg')+'.tif'
tiffind = jsofind.rstrip('.jpg')+'.tif'

#FIXME: oh where are the tifs. please send in the tifs.
print '/tif_path/'+tifidenti,'or'
print '/tif_path/'+tiffind

jsod = json.dumps(jso, sort_keys=True, indent=4)
jsods = str(jsod)

openone = '<html><body><pre><code>'
closone = '</code></pre>'
opentwo = '<pre>'
clostwo = '</pre></body></html>'

drafttifpath = 'http://base_url2/some_locally_accessible_tif_path/'+tifidenti
drafttifhtml = '<p><a href="'+drafttifpath+'">'+drafttifpath+'</a></p>'

with open('/tmp/workfile','w') as jsof: #FIXME Per paths adjustment above, and, we need to run on Windows
	jsof.write(openone)
	jsof.write(jsods)
	jsof.write(closone)
	jsof.write(opentwo)
	jsof.write(drafttifhtml)
	jsof.write(clostwo)

print jsof.closed

