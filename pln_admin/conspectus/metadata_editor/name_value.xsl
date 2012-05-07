<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:dc="http://purl.org/dc/elements/1.0/"
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:cld="http://www.ukoln.ac.uk/metadata/rslp/1.0/"
xmlns:ma="http://metaarchive.org/public/resources/conspectus_metadata_schema.html"
>

<xsl:output method="xml" version="1.0" /> 

<xsl:template match="/error" priority="2">
	<error> </error>
</xsl:template>

<xsl:template match="/rdf:RDF" priority="2">
	<list> 
	<xsl:apply-templates/>
	</list>
</xsl:template>

<xsl:template match="dc:title" priority="2">
<pair>
<name>Title:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dcterms:alternate" priority="2">
<pair>
<name>Alternate Title:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dcterms:temporal" priority="2">
<pair>
<name>Temporal Coverage:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dcterms:spatial" priority="2">
<pair>
<name>Spatial Coverage:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="cld:dateContentsCreated" priority="2">
<pair>
<name>Contents Date Range:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dc:created" priority="2">
<pair>
<name>Accumulation Date Range:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dcterms:temporal" priority="2">
<pair>
<name>Temporal Coverage:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dc:identifier" priority="2">
<pair>
<name>Identifier:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="ma:isAvailableVia" priority="2">
<pair>
<name>Is Available Via:</name>
<value><a href="{text()}"><xsl:value-of select="text()"/></a></value>
</pair>
</xsl:template>

<xsl:template match="dc:subject" priority="2">
<xsl:apply-templates select="*/rdf:value" />
</xsl:template>

<xsl:template match="ma:ESC/rdf:value" priority="2">
<pair>
<name>ESC Heading:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dc:LCSH/rdf:value" priority="2">
<pair>
<name>LCSH Heading:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dc:MESH/rdf:value" priority="2">
<pair>
<name>MESH Heading:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="cld:accrualPeriodicity" priority="2">
<pair>
<name>Accrual Periodicity:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="cld:accrualPolicy" priority="2">
<pair>
<name>Accrual Policy:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dc:format" priority="2">
<pair>
<name>Format:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dc:language" priority="2">
<pair>
<name>Language:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dc:type" priority="2">
<pair>
<name>Type:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dcterms:extent" priority="2">
<pair>
<name>Extent:</name>
<value><xsl:value-of select="text()"/> bytes</value>
</pair>
</xsl:template>

<xsl:template match="dc:creator" priority="2">
<pair>
<name>Creator:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dc:publisher" priority="2">
<pair>
<name>Publisher:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dc:rights" priority="2">
<pair>
<name>Rights:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dcterms:accessRights" priority="2">
<pair>
<name>Access Rights:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dcterms:provenance" priority="2">
<pair>
<name>Custodial History:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="ma:manifestation" priority="2">
<pair>
<name>Manifestation:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dcterms:isReferencedBy" priority="2">
<pair>
<name>Is Referenced By:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dcterms:hasPart" priority="2">
<pair>
<name>Subcollection:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dcterms:isPartOf" priority="2">
<pair>
<name>Supercollection:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="cld:hasDescription" priority="2">
<pair>
<name>Catalogueor Collection:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="ma:cataloguedStatus" priority="2">
<pair>
<name>Catalogued Status:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="dc:relation" priority="2">
<pair>
<name>Related Collection:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="ma:harvestProc" priority="2">
<pair>
<name>Harvesting Procedure:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="ma:manifest" priority="2">
</xsl:template>

<xsl:template match="ma:OAIProvider" priority="2">
<pair>
<name>OAI Provider:</name>
<value><a href="{text()}"><xsl:value-of select="text()"/></a></value>
</pair>
</xsl:template>

<xsl:template match="ma:riskRank" priority="2">
<pair>
<name>Risk Rank:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

<xsl:template match="ma:plugin" priority="2">
</xsl:template>

<xsl:template match="ma:riskFactors" priority="2">
<pair>
<name>Risk Factors:</name>
<value><xsl:value-of select="text()"/></value>
</pair>
</xsl:template>

</xsl:stylesheet>
