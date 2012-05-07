<?php

include_once("mysql_includes.php");
include_once("config.php");

mysql_connect(dbhost, dbuser, dbpass);
mysql_select_db(dbname);

function log_prefix() 
{
    $ip = $_SERVER['SERVER_ADDR']; 
    $uri = $_SERVER['REQUEST_URI']; 
    return date(DATE_RFC822) . "	$ip	$uri"; 
}


function mysql_log_query($sql){
    global $logFile;
    $rc = mysql_query($sql);
    if ($logFile) { 
       // log ip address, username, query
       $log_sql = log_prefix() . "	" . ($rc ? $rc : "ERROR") . " $sql";
       fwrite( $logFile,  $log_sql . "\n"); 
    }
    return $rc; 
}

function log_msg($str) 
{
 global $logFile;
 if ($logFile) {
    fwrite($logFile, log_prefix() . "	$str\n"); 
 }
}


function html_link($dest, $text) {
   if (!$text) {
      $text = htmlspecialchars($dest); 
   } else {
      $text = htmlspecialchars($text); 
   }
	return "<a href='$dest'>$text</a>"; 
} 

function html_table_begin($extra = "") 
{
	return "\n<table width='100%' $extra>\n";
}

function html_table_end() 
{
	return "\n</table>\n";
}


function html_td($what, $extra = "") 
{
	return "<td $extra> $what </td>"; 
}

function html_tr($what, $extra = "") 
{
	return "<tr $extra> $what </tr>\n"; 
}

function html_page_start()
{
 global $conspectus_url; 
 $template = "includes/header.ihtml";
 $f = fopen($template, "r"); 
 $str = fread($f, filesize($template)); 
 $new_str = str_replace("{CONSPECTUS_URL}",  $conspectus_url, $str); 
 echo($new_str); 
}

function html_page_stop() 
{
	echo "</body></html>"; 
}

function conspectusPerdiodicutyToDays($per) 
{
	switch ($per) {
		case 'daily' : return 1; 
		case 'weekly' : return 7; 
		case 'monthly' : return 30; 
		case 'quarterly' : return 90; 
		case 'semi-annually' : return 182; 
		case 'yearly' : return 364; 
		case 'no longer' : return 364; 
	}
	return -1; // undefined
}

function get_col_id($plugin, $base_url)
{
	$query = "SELECT collection.id FROM `collection` JOIN plugin " . 
	     "WHERE collection.id = plugin.collection_id AND  " . 
		 "collection.`about` = '" . $base_url . "' AND " . 
		 "plugin.`value` = '" . $plugin  . "'";  
	$result = mysql_query($query);
	if ($result) {
		if ($arr = mysql_fetch_array($result)) { 
			$coll_id = $arr[0];
			return $coll_id;
		}
	} 
	return -1;  	
}


?>
