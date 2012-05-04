<?php 
$format = 'csv'; 
$list_undef = $_GET['list_undef']; 
if ($list_undef) {
	$format = 'html';
	include_once('utils.php');
	html_page_start();
	print "<h2> Collections without plugin and publisher </h2>"; 
}
if ($format == 'csv') {
	header("Content-type: text/csv");  
	header("Cache-Control: no-store, no-cache");  
	header('Content-Disposition: attachment; filename="filename.csv"');  
} 
$outstream = fopen("php://output",'w'); 
$header = array( "id", "plugin_name", "base_url", "title", "description");
if ($format == 'csv') {
		fputcsv($outstream, $header, ",");	
}
	
include_once('trace.php');
include_once('types.php');
include_once('fetch_data.php');
include_once("mysql_includes.php");


mysql_connect(dbhost, dbuser, dbpass);
mysql_select_db(dbname);


$get_publisher = "SELECT publisher.value AS publisher_name " .
            " FROM publisher  " . 
			" WHERE     publisher.collection_id = "; 
			
$query = "SELECT collection.id AS id, " .
			"       plugin.value AS plugin_name, " .
			"       collection.about AS baseurl, " .
            "       collection.collection_title AS title, " .
            "       collection.collection_desc AS description " .
			" FROM collection ". 
            " LEFT JOIN plugin " .
			" ON collection.id = plugin.collection_id " .
			" ORDER BY collection.id ASC";

			

$result = mysql_log_query($query);

while ($coll = mysql_fetch_assoc($result)) {
	if (!$coll['baseurl']) {
		$coll['baseurl'] = "http://undefined";
	}
	if (!$coll['plugin_name']) { 
	    /*  derive from publisher name  */
		$get_pub = mysql_log_query( $get_publisher . $coll['id'] ); 
		$pub = mysql_fetch_assoc($get_pub);
		$pub_name = $pub['publisher_name']; 
		if ($pub_name) { 
			  $coll['plugin_name'] = "edu." . strtolower($pub_name) . ".NONE"; 
		} else {
			  if ($list_undef) {
			  	if (empty($coll["title"])) { $coll["title"] = "UNDEFIND"; }
				print "<a href='edit.php?coll_id=" . $coll['id'] . "'>" . $coll['title'] . "</a><br/>"; 
				print "\n";  
			  }
		}
	} 
	if ($format == 'csv') {
		fputcsv($outstream, $coll, ",");
	}
}



?>
