<?php
header("Content-type: text/xml");

include_once("config.php");
include_once('fetch_data.php');
include_once("utils.php");
include_once("generate_item.php");
include_once('rdf.php');

if(!$_GET['coll_id']) {   
   echo "<error code=\"1\">Please pass collection id.</error>\n";
   die();
}
$coll_id = $_GET['coll_id']; 

$coll_data = fetch_collection($coll_id);
$xml = rdf($coll_data); 
	
/* create xml doc  */
$xml_doc = new DOMDocument();
$xml_doc->loadXML( $xml ); 

if (!$xml_doc) {
    $errors = libxml_get_errors();

    foreach ($errors as $error) {
        echo display_xml_error($error, $xml);
    }

    libxml_clear_errors();
    die(); 
}
   $xslt = new XSLTProcessor(); 
   $xsl_doc = new DOMDocument(); 
   $xsl_doc->load( 'conspectus_metadata.xsl', LIBXML_NOCDATA); 
   $xslt->importStylesheet( $xsl_doc );
   $xml =  $xslt->transformToXML( $xml_doc ); 

   $xml = str_replace('<?xml version="1.0"?>', "", $xml);
   print str_replace("\n", "", $xml);
?>

