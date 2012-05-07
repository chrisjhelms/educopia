<?php
include_once("mysql_includes.php");
include_once("utils.php");
include_once("generate_item.php");
include_once("subjects.php");

function rdf($coll_data) {
$str =  "<rdf:RDF\n" . 
      "xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n" .
      "xmlns:dc=\"http://purl.org/dc/elements/1.0/\"\n" .
      "xmlns:dcterms=\"http://purl.org/dc/terms/\"\n" .
      "xmlns:gen=\"http://example.org/gen/terms#\"\n" .
      "xmlns:cld=\"http://www.ukoln.ac.uk/metadata/rslp/1.0/\"\n" .
      "xmlns:ma=\"http://metaarchive.org/metadata/\"\n" .
      "xmlns:mods=\"http://www.loc.gov/standards/mods/v3/\"\n" . 
      ">\n";
       

   $str .= "<rdf:Description>\n";
   $str .= "<ma:collectionid>" . $coll_data["ma_collection_id"] ."</ma:collectionid>";
   
   $str .= "\n<!--Descriptive Data-->\n";
   $str .= generate_list($coll_data,'alternative_title','dcterms:alternate');
   $str .= generate_esc_subject($coll_data,'esc_subject','ma:ESC');
   $str .= generate_subject($coll_data,'lcsh_subject','dc:LCSH');
   $str .= generate_subject($coll_data,'mesh_subject','dc:MESH');
   $str .= "\n";
   
   $str .= "<!--URIs--> \n";
   $str .= generate_list($coll_data,'identifier','dc:identifier');
   $str .= generate_list($coll_data,'isavailablevia','ma:isAvailableVia');
   $str .= "\n";
   
   $str .= "<!--Coverage-->\n";
   $str .= generate_list($coll_data,'spatialcoverage','dcterms:spatial');
   $str .= generate_list($coll_data,'temporalcoverage','dcterms:temporal');
   $str .= generate_date_ranges($coll_data,'created','dc:created');
   $str .= generate_date_ranges($coll_data,'date_contents_created','cld:dateContentsCreated');
   $str .= "\n"; 

   $str .= "<!--Accrual Information-->"; 
   $str .= generate_single_text($coll_data,'accrualperiodicity','cld:accrualPeriodicity');
   $str .= generate_single_text($coll_data,'accrualpolicy','cld:accrualPolicy');
   $str .= "\n"; 
   
   $str .= "<!--Data Description-->\n";
   $str .= generate_format($coll_data,'format','dc:format');
   $str .= generate_list($coll_data,'language','dc:language');
   $str .= generate_type($coll_data,'type','dc:type');
   $str .= generate_single_text($coll_data,'extent','dcterms:extent');
   $str .= "\n"; 

   $str .= "<!--Rights and Ownership-->\n";
   $str .= generate_list($coll_data,'creator','dc:creator');
   $str .= generate_list($coll_data,'publisher','dc:publisher');
   $str .= generate_list($coll_data,'rights','dc:rights');
   $str .= generate_single_text($coll_data,'accessrights','dcterms:accessRights');
   $str .= generate_single_text($coll_data,'provenance','dcterms:provenance');
   $str .= generate_list($coll_data,'manifestation','ma:manifestation');
   $str .= "\n"; 

   $str .= "<!--Related Resources-->\n";
   $str .= generate_list($coll_data,'isreferencedby','dcterms:isReferencedBy');
   $str .= generate_list($coll_data,'haspart','dcterms:hasPart');
   $str .= generate_list($coll_data,'ispartof','dcterms:isPartOf');
   $str .= generate_list($coll_data,'catalogueor','cld:hasDescription');
   $str .= generate_catalogued_status($coll_data,'catalogued_status','ma:cataloguedStatus');
   $str .= generate_list($coll_data,'relation','dc:relation');
   $str .= "\n"; 

   $str .= "<!--Harvesting Information-->\n";
   $str .= generate_single_text($coll_data,'riskrank','ma:riskRank');
   $str .= generate_single_text($coll_data,'risk_factors','ma:riskFactors');
   $str .= "</rdf:Description>\n";

$str .= "</rdf:RDF>\n";
return $str;
}
