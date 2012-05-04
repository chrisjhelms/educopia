<?php

$doc = new DOMDocument();
$xsl = new XSLTProcessor();
$xsl_filename="metaarchive.xsl";
$doc->load($xsl_filename);
$xsl->importStyleSheet($doc);

function gen_multiple($colls) {
	foreach ($colls as $coll) {
                echo "Smartech Collection : $coll <br/>";
		$xml_filename="http://smartech.gatech.edu/oai/request?verb=ListIdentifiers&metadataPrefix=mets&set=hdl_1853_$coll";
		xml_out($doc,$xml_filename,$xsl);
		}
}

function gen_single($coll) {
        echo "Smartech Collection : $coll <br/>";
	$xml_filename="http://smartech.gatech.edu/oai/request?verb=ListIdentifiers&metadataPrefix=mets&set=hdl_1853_$coll";
	xml_out($doc,$xml_filename,$xsl);
	}
	
function gen_partial($coll,$start,$end) {
        echo "Smartech Collection : $coll <br/>";
	$xml_filename= "http://smartech.gatech.edu/oai/request?verb=ListIdentifiers&metadataPrefix=mets&set=hdl_1853_$coll&from=$start&until=$end";
	xml_out($doc,$xml_filename,$xsl);
}

function xml_out($doc,$xml_filename,$xsl) {
        include "vars.php";
	$doc->load($xml_filename);
	echo $xsl->transformToXML($doc);
}


?>
