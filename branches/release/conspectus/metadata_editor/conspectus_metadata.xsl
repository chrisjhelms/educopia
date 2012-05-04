<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:dc="http://purl.org/dc/elements/1.0/"
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:cld="http://www.ukoln.ac.uk/metadata/rslp/1.0/"
xmlns:ma="http://metaarchive.org/public/resources/conspectus_metadata_schema.html"
>

<xsl:template match="/error" priority="2">
	<error> 
		<xsl:value-of select="text()"/>
	</error>
</xsl:template>

<xsl:template match="/rdf:RDF" priority="2">
		<xsl:apply-templates />
</xsl:template>

<xsl:template match="rdf:Description" priority="2">
<metadata>

<xsl:for-each select='dc:title'>
  <item field='dc:title' >
    <label> dc:title </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dcterms:alternate'>
  <item field='dcterms:alternate' >
    <label> dcterms:alternate </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dcterms:temporal'>
  <item field='dcterms:temporal' >
    <label> dcterms:temporal </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dcterms:spatial'>
  <item field='dcterms:spatial' >
    <label> dcterms:spatial </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='cld:dateContentsCreated'>
  <item field='cld:dateContentsCreated' >
    <label> cld:dateContentsCreated </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dc:created'>
  <item field='dc:created' >
    <label> dc:created </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dc:identifier'>
  <item field='dc:identifier' >
    <label> dc:identifier </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='ma:isAvailableVia'>
  <item field='ma:isAvailableVia' >
    <label> ma:isAvailableVia </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='cld:accrualPeriodicity'>
  <item field='cld:accrualPeriodicity' >
    <label> cld:accrualPeriodicity </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='cld:accrualPolicy'>
  <item field='cld:accrualPolicy' >
    <label> cld:accrualPolicy </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dc:format'>
  <item field='dc:format' >
    <label> dc:format </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dc:language'>
  <item field='dc:language' >
    <label> dc:language </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dc:type'>
  <item field='dc:type' >
    <label> dc:type </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dcterms:extent'>
  <item field='dcterms:extent' >
    <label> dcterms:extent </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dc:creator'>
  <item field='dc:creator' >
    <label> dc:creator </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dc:publisher'>
  <item field='dc:publisher' >
    <label> dc:publisher </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dc:rights'>
  <item field='dc:rights' >
    <label> dc:rights </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dcterms:accessRights'>
  <item field='dcterms:accessRights' >
    <label> dcterms:accessRights </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dcterms:provenance'>
  <item field='dcterms:provenance' >
    <label> dcterms:provenance </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='ma:manifestation'>
  <item field='ma:manifestation' >
    <label> ma:manifestation </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dcterms:isReferencedBy'>
  <item field='dcterms:isReferencedBy' >
    <label> dcterms:isReferencedBy </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dcterms:hasPart'>
  <item field='dcterms:hasPart' >
    <label> dcterms:hasPart </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dcterms:isPartOf'>
  <item field='dcterms:isPartOf' >
    <label> dcterms:isPartOf </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='dc:relation'>
  <item field='dc:relation' >
    <label> dc:relation </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='cld:hasDescription'>
  <item field='cld:hasDescription' >
    <label> cld:hasDescription </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='ma:cataloguedStatus'>
  <item field='ma:cataloguedStatus' >
    <label> ma:cataloguedStatus </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='ma:OAIProvider'>
  <item field='ma:OAIProvider' >
    <label> ma:OAIProvider </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='ma:riskRank'>
  <item field='ma:riskRank' >
    <label> ma:riskRank </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
<xsl:for-each select='ma:riskFactors'>
  <item field='ma:riskFactors' >
    <label> ma:riskFactors </label> 
    <value> <xsl:value-of select='text()' /> </value>
  </item> 
</xsl:for-each>  
</metadata>
</xsl:template>

</xsl:stylesheet>
