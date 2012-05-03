<?php
$url= $_GET["request"] . "?verb=ListRecords&metadataPrefix=oai_dc&set=". $_GET["set"]; 
$xsl= $_GET["xsl"]; 
$cmd = "xsltproc $xsl.xsl '$url'";
print system($cmd);
?>


