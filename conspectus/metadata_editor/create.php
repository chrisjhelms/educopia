<?php 
header("Content-type: text/xml");

include_once('config.php');
include_once('trace.php');
include_once('types.php');
include_once('fetch_data.php');
include_once("mysql_includes.php");

mysql_connect(dbhost, dbuser, dbpass);
mysql_select_db(dbname);

$query = "INSERT INTO collection () VALUES()";
$res = mysql_log_query($query); 
if (!$res) {
    	echo "$query"; 
        echo mysql_error();
		die(); 
}  else { 
		echo("<collection>"); 
       	echo('<id type="integer">' . mysql_insert_id() . "</id>");
		echo("</collection>"); 
}
		
?>
