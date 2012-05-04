<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
            "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Georgia Tech Campus Publications Manifest Page - Blueprint</title>
</head>
<body>
<h2>Blueprint, Part 1 <h2> 
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
<i>Blueprint</i>, the Georgia Tech Yearbook
<ul>
	<li>Blueprint</li>
</ul>
	
</p> 
<p>Links for LOCKSS to start its crawl:</p>

<?php

include "metaarchive.php";
$coll = 12189;
$start = '2006-10-24T20:15:34Z';
$end = '2008-11-03T15:15:17Z';
gen_partial($coll,$start,$end);
?>

</body>
</html>
