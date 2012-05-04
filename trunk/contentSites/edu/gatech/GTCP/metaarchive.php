<?php
$dspace = "http://smartech.gatech.edu";
$dspace_handle = "$dspace/handle/1853";
$xsl_filename="metaarchive.xsl";

function dspace_link($hdl_id)
{
	global $dspace_handle;
	return "<a href='$dspace_handle/$hdl_id'> $hdl_id </a>";
}

function gen_single($coll) {
	global $dspace;
	echo "Smartech Collection : " . dspace_link($coll) . "<br/>";
	$xml_filename="$dspace/oai/request?verb=ListIdentifiers&metadataPrefix=mets&set=hdl_1853_$coll";
	xml_trans($xml_filename);
}

function gen_partial($coll,$start,$end) {
	global $dspace;
	echo "Smartech Collection : " . dspace_link($coll). " <br/>";
	echo "Date Range: $start to $end <br/>";
	$xml_filename= "$dspace/oai/request?verb=ListIdentifiers&metadataPrefix=mets&set=hdl_1853_$coll&from=$start&until=$end";
	xml_trans($xml_filename);
}

function xml_trans($xml_filename) {
	global $xsl_filename;
	$doc = new DOMDocument();
	$xsl = new XSLTProcessor();
	$doc->load($xsl_filename);
	$xsl->importStyleSheet($doc);
	$doc->load($xml_filename);
	echo $xsl->transformToXML($doc);
}

?>
