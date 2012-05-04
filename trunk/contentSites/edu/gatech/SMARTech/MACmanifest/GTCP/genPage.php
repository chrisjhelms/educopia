<?php
include "metaarchive.php";

function genSubManifestPage($title, $subtitle, $manifest, $colls)
{
	echo "<html>\n";
	echo "<head>\n";
	echo "<title>$title : $subtitle </title>\n";
	echo "</head>\n";

	echo "<body>\n";
	echo "<h2>$title : $subtitle </h2>\n";
	permission();

	echo "<p>Collection Info: Part of <a href='$manifest'>$title Manifest Page</a> </p> \n";
	echo "<p>Links for LOCKSS to continue crawling </p> \n";
	echo " <table> \n";
	echo " <thead> \n";
	echo " <tr> \n";
	echo " <td> Collection </td> \n";
	echo " <td> &nbsp; </td> \n";
	echo " </tr> \n";
	foreach ($colls as $id)  {
		print "<tr><td> \n";
		print "  <a href='http://smartech.gatech.edu/handle/1853/$id'> hdl_id: $id </a>\n";
		print "</td><td>\n";
		print "  <a href='itemListPage.php?hdlid=$id&manifest=$manifest&title=$title&subtitle=$subtitle'> items </a>"  ;
		print "</td></tr> \n";
	}
	echo "</table> \n";
	echo "</body>\n";

	echo "</html>\n";
}

function genItemListPage($title, $subtitle, $manifest, $hdlid)
{
	echo "<html>\n";
	echo "<head>\n";
	echo "<title>Item List: $title / $subtitle / $hdlid </title>\n";
	echo "</head>\n";

	echo "<body>\n";
	echo "<h2>Item List: $title / $subtitle / $hdlid </h2>\n";
    permission();
	echo "<p>Part of <a href='$manifest'>$title Manifest Page</a> </p> \n";
	echo "<p>Links for LOCKSS to continue crawling </p> \n";
	gen_single($hdlid); 
	echo "</body>\n";
    
	echo "</html>\n";
}

function genPartialItemPage($title, $subtitle, $manifest, $hdlid, $start, $stop)
{
	echo "<html>\n";
	echo "<head>\n";
	echo "<title>Item List: $title / $subtitle / $hdlid </title>\n";
	echo "</head>\n";

	echo "<body>\n";
	echo "<h2>Item List: $title / $subtitle / $hdlid </h2>\n";
    permission();
	echo "<p>Part of <a href='$manifest'>$title Manifest Page</a> </p> \n";
	echo "<p>Links for LOCKSS to continue crawling </p> \n";
	gen_partial($hdlid, $start, $stop); 
	echo "</body>\n";
    
	echo "</html>\n";
}


function permission()
{
    echo "<h4> \n";
	echo "<img alt='MetaArchive logo' src='http://www.metaarchive.org/public/images/favicon.ico'> \n";
	echo "Manifest Page to Allow preservation by <a href='http://www.lockss.org'> LOCKSS  </a> daemons in the \n";
	echo "<A href='http://www.metaarchive.org'> MetaArchive Network </a>  \n";
	echo "<br/> \n";
	echo "<img alt='LOCKSS logo' src='http://www.lockss.org/favicon.ico'> LOCKSS system has permission to collect, preserve, and serve this Archival Unit.\n";
	echo "</h4> \n";
	
}
?>