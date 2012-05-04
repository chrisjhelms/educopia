<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
            "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Georgia Tech Campus Publications Manifest Page - Miscellaneous, Part 1</title>
</head>
<body>
<h2> Technique<h2> 
<h4> LOCKSS Manifest Page</h4>

<p>Collection Info:</p>
<ul>
        <li>Conspectus Collection(s): <a href="http://admin.metaarchive.org:6331/collections/150">Georgia Tech Campus Publications</a> </li> 
        <li>Institution: Georgia Tech</li>
        <li>Contact Info: <a href="mailto:ryan.speer@library.gatech.edu">Ryan Speer</a></li>
</ul>
<p><img alt="LOCKSS logo" src="http://www.lockss.org/LOCKSS.logo.1%27.gif" />LOCKSS system has permission to collect, preserve, and serve this Archival Unit.</p>
<p>
COLLECTION_DESCRIPTION <br/>
Miscellaneous small collections from SMARTech:
<ul>
	<li>The Classroom</li>
	<li>College of Architecture Brochures</li>
	<li>College of Architecture Newsletters</li>
	<li>PhD Focus</li>
	<li>Urban Connections</li>
	<li>FIREwall</li>
	<li>IE Connections</li>
	<li>ECE Brochures</li>
	<li>ECE Connection</li>
	<li>ECE Strategic Plans</li>
	<li>Annual Founder's Day Celebration</li>
	<li>Ivan Allen College Brochures</li>
	<li>Ivan Allen College Newsletters</li>
	<li>LINK (Student Advisory Board Newsletter)</li>
	<li>College of Managment Annual Reports</li>
	<li>College of Management Brochures, Fact Sheets and Calendars</li>
	<li>Proofreader</li>
	<li>The Whistle</li>
</ul>
</p> 
<p>Links for LOCKSS to start its crawl:</p>

<?php
include "metaarchive.php";
$colls = array(9,18852,1771,14704,14696,25541,6049,26293,5998,18812,32473,8105,8729,10692,10691,23884,3790) ;
gen_multiple($colls);
?>

</body>
</html>
