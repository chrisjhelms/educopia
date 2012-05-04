<?php

include_once('trace.php');
include_once("mysql_includes.php");

print "mysqldump " ; 
print " -u" . dbuser; 
print " -p" . dbpass; 
print " " . dbname ; 
?>

