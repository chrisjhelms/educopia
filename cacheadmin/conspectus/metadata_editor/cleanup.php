<?php 

include_once('trace.php');
include_once('types.php');
include_once('fetch_data.php');
include_once("mysql_includes.php");

mysql_connect(dbhost, dbuser, dbpass);
mysql_select_db(dbname);

$query = "DELETE  FROM `collection` WHERE `collection_title` is NULL AND `about` is NULL";
$res = mysql_log_query($query); 
if (!$res) {
    	echo "$query"; 
        echo mysql_error();
		die(); 
}  else { 
		print "deleted lots of empty collections";
}
		
?>
