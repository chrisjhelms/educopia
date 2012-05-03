<?php
$url="http://smartech.gatech.edu/dspace-oai/request?verb=ListRecords&metadataPrefix=oai_dc&set=". $_GET["set"]; 
$cmd = "xsltproc ./oai2.xsl '$url'";
print system($cmd);
?>


