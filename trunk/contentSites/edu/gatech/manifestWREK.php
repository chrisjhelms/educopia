<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
            "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Georgia Tech Campus Publications Manifest Page - WREK</title>
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
SMARTech collections for the WREK community (Georgia Tech's student-run radio station)
<ul>
	<li>Inside the Black Box</li>
	<li>Tech Talk</li>
</ul>
</p> 
<p>Links for LOCKSS to start its crawl:</p>

<?php
include "metaarchive.php";
$colls = array(26990,7319) ;
gen_multiple($colls);
?>
</body>
</html>
