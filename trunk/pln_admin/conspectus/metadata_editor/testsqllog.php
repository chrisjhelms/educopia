<?php
header("Content-type: text/plain");  

include_once("config.php");
include_once('fetch_data.php');
include_once("utils.php");
include_once("generate_item.php");
include_once('rdf.php');

print $logFileName . "\n";
print $logFile . "\n"; 

$res = mysql_log_query('SELECT * FROM collections'); 
