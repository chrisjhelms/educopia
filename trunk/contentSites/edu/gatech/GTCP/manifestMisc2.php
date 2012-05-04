<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
            "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Georgia Tech Campus Publications Manifest Page - Miscellaneous, Part 2</title>
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
	<li>Agenda and Minutes of the Academic Senate and General Faculty Assembly</li>
	<li>Agenda and Minutes of the Executive Board</li>
	<li>Faculty Governance Committee Minutes</li>
	<li>Faculty Governance Election Materials</li>
	<li>Georgia Tech Faculty Handbook</li>
	<li>Membership Lists of Faculty Governance Bodies and Standing Faculty Committees</li>
	<li>Georgia Tech Alumni Magazine</li>
	<li>Tech Topics</li>
</ul>
</p> 
<p>Links for LOCKSS to start its crawl:</p>

<?php
include "metaarchive.php";
$colls = array(26330,25038,9539,10160) ;
gen_multiple($colls);
?>

</body>
</html>
