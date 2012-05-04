<?php

        $doc = new DOMDocument();
        $xsl = new XSLTProcessor();
        $xsl_filename="metaarchive.xsl";
        $doc->load($xsl_filename);
        $xsl->importStyleSheet($doc);

?>
