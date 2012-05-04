<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
            "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Georgia Tech Campus Publications Manifest Page - Miscellaneous, Part 4</title>
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
	<li>SACS Accreditation (2005)</li>
	<li>Georgia Tech Fact Book</li>
	<li>Academic Integrity Newsletter</li>
	<li>Academic Violation Statistics</li>
	<li>Student Code of Conduct</li>
	<li>Georgia Institute of Technology Annual Reports</li>
	<li>Georgia Institute of Technology Strategic Plans</li>
	<li>Office of the President Publications</li>
	<li>President's Speeches and Presentations</li>
	<li>Return on Investment</li>
	<li>State of the Institute</li>
	<li>IBB Faculty Profiles</li>
	<li>President's Scholarship Newsletters</li>
	<li>The Tower</li>
	<li>Undergraduate Research News</li>
	<li>Undergraduate Research Kaleidoscope</li>
</ul>
</p> 
<p>Links for LOCKSS to start its crawl:</p>

<?php
include "metaarchive.php";
$colls = array(12192,5868,13246,13256,13252,13238,20618,16976,10893,13242,12182,28907,4740,26926,12295,27725) ;
gen_multiple($colls);
?>

</body>
</html>
