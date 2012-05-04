<?php 
header("Content-type: text/html");
include_once('types.php');
include_once('edit_rdf.php');
include_once('fetch_data.php');
include_once('utils.php');
include_once('format_input.php');
include_once('update_data.php');
include_once('utils.php');

html_page_start(); 
if ($_POST) { 
  $arr = format_input($_POST);
  $coll_id = update_collection($arr);
#print_r($arr); 
  $coll_title = $_POST['title']; 
} else {
	if(!$_GET['coll_id']) {	
		echo "Please include collection coll_id parameter\n"; 
		die();
	}

	$coll_id = $_GET['coll_id']; 
	$coll_title = $_GET['title']; 
}

$coll_data = fetch_collection($coll_id);
if (empty($coll_title)) {
	 $coll_title = $coll_data['collection_title'];
}
if (empty($coll_title)) {
	$coll_title = "UNDEFINED Collection Title"; 
}
?> 

<div id="page_header"><h2>Meta Data Editor</h2></div>
	
<?php

if (!empty($coll_title)) {
	echo "<h3>" . $coll_title. "</h3>"; 
}

echo edit_rdf($coll_data, $coll_title);

html_page_stop(); 
?>
