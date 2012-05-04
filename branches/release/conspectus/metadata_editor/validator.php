<?php
header("Content-type: text/xml");
echo "<?xml version=\"1.0\"?>\n";
echo "<?xml-stylesheet href=\"validate.xsl\" type=\"text/xsl\" ?>\n";

include_once('types.php');
include_once('validate.php');
include_once('fetch_data.php');

if(!$_GET['collection']) {
echo "<!-- Collection_id not specified -->\n";
echo "<error code=\"1\">Please specify a collection to view.</error>\n";
die();
}

$coll_id = $_GET['collection'];

$coll_data = fetch_collection($coll_id);

if (0) {  
foreach($coll_data as $key => $value) {
       echo ( $key ."='" . $value . "'\n"); 
    }
}

echo validate($coll_data);

?>
