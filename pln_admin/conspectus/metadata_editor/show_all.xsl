<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:dc="http://purl.org/dc/elements/1.0/"
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:gen="http://example.org/gen/terms#"
xmlns:cld="http://www.ukoln.ac.uk/metadata/rslp/1.0/"
xmlns:ma="http://metaarchive.org/public/resources/conspectus_metadata_schema.html"
xmlns:mods="http://www.loc.gov/standards/mods/v3/"
xmlns="http://www.w3.org/1999/xhtml">

<xsl:output method="xml" indent="yes"
	doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
	doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" />

<xsl:template match="/error" priority="2">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>
	<title>Error</title>
	</head>
	<body>
	<h2>There was an error processing your request.</h2>
	<p><xsl:value-of select="text()"/></p>
	</body>
	</html>
</xsl:template>

<xsl:template match="/rdf:RDF" priority="2">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>
	<title>SDC Metaa Data </title>
	<style type="text/css">
	div.collection {
		border: 2px dotted #151515;
		background-color: #f4f4f4;
		margin-bottom: 10px;
		padding: 6px;
	}
	span.title {
		font-size: 20px;
	}
	td.itemtype {
		width: 25%;
		font-weight: bold;
		text-align: right;
		vertical-align: top;
	}
	table.rdfdesc {
		border: 0px dotted #151515;
		border-top-width: 2px;
		width: 100%;
		margin-top: 2px;
	}
	td.itemval {
		border: 0px dotted #151515;
		border-bottom-width: 1px;
	}
	</style>
	</head>
	<body>

<div class="page_title"> 
      <h1> Conspectus </h1>
</div>   
   
<p>

<div class="menu">
   <span> <a href="http://conspectus.metaarchive.org/archives">archives</a> </span> 
   | 
   <span> <a href="http://conspectus.metaarchive.org/content_providers">content providers</a> </span> 
   | 
   <span> <a href="http://conspectus.metaarchive.org/collections">collections</a> </span> 
   | 
   <span> <a href="http://conspectus.metaarchive.org/plugins">plugins</a> </span> 
</div>  
</p>


	<xsl:apply-templates/>
	</body>
	</html>
</xsl:template>

<xsl:template match="rdf:Description" priority="2">
<div class="collection">
	<table class="rdfdesc">
		<xsl:apply-templates/>
	</table>
</div>
</xsl:template>

<xsl:template match="*" priority="1">
</xsl:template>

<xsl:template match="dc:title" priority="2">
<tr>
<td class="itemtype">Title:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dcterms:alternate" priority="2">
<tr>
<td class="itemtype">Alternate Title:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dcterms:temporal" priority="2">
<tr>
<td class="itemtype">Temporal Coverage:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dcterms:spatial" priority="2">
<tr>
<td class="itemtype">Spatial Coverage:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="cld:dateContentsCreated" priority="2">
<tr>
<td class="itemtype">Contents Date Range:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dc:created" priority="2">
<tr>
<td class="itemtype">Accumulation Date Range:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dcterms:temporal" priority="2">
<tr>
<td class="itemtype">Temporal Coverage:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dc:identifier" priority="2">
<tr>
<td class="itemtype">Identifier:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="ma:isAvailableVia" priority="2">
<tr>
<td class="itemtype">Is Available Via:</td>
<td class="itemval"><a href="{text()}"><xsl:value-of select="text()"/></a></td>
</tr>
</xsl:template>

<xsl:template match="dc:subject" priority="2">
<xsl:apply-templates select="*/rdf:value" />
</xsl:template>

<xsl:template match="ma:ESC/rdf:value" priority="2">
<tr>
<td class="itemtype">ESC Heading:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dc:LCSH/rdf:value" priority="2">
<tr>
<td class="itemtype">LCSH Heading:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dc:MESH/rdf:value" priority="2">
<tr>
<td class="itemtype">MESH Heading:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="cld:accrualPeriodicity" priority="2">
<tr>
<td class="itemtype">Accrual Periodicity:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="cld:accrualPolicy" priority="2">
<tr>
<td class="itemtype">Accrual Policy:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dc:format" priority="2">
<tr>
<td class="itemtype">Format:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dc:language" priority="2">
<tr>
<td class="itemtype">Language:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dc:type" priority="2">
<tr>
<td class="itemtype">Type:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dcterms:extent" priority="2">
<tr>
<td class="itemtype">Extent:</td>
<td class="itemval"><xsl:value-of select="text()"/> bytes</td>
</tr>
</xsl:template>

<xsl:template match="dc:creator" priority="2">
<tr>
<td class="itemtype">Creator:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dc:publisher" priority="2">
<tr>
<td class="itemtype">Publisher:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dc:rights" priority="2">
<tr>
<td class="itemtype">Rights:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dcterms:accessRights" priority="2">
<tr>
<td class="itemtype">Access Rights:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dcterms:provenance" priority="2">
<tr>
<td class="itemtype">Custodial History:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="ma:manifestation" priority="2">
<tr>
<td class="itemtype">Manifestation:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dcterms:isReferencedBy" priority="2">
<tr>
<td class="itemtype">Is Referenced By:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dcterms:hasPart" priority="2">
<tr>
<td class="itemtype">Subcollection:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dcterms:isPartOf" priority="2">
<tr>
<td class="itemtype">Supercollection:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="cld:hasDescription" priority="2">
<tr>
<td class="itemtype">Catalogueor Collection:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="ma:cataloguedStatus" priority="2">
<tr>
<td class="itemtype">Catalogued Status:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="dc:relation" priority="2">
<tr>
<td class="itemtype">Related Collection:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="ma:harvestProc" priority="2">
<tr>
<td class="itemtype">Harvesting Procedure:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="ma:manifest" priority="2">
<tr>
<td class="itemtype">Manifest Page:</td>
<td class="itemval"><a href="{text()}"><xsl:value-of select="text()"/></a></td>
</tr>
</xsl:template>

<xsl:template match="ma:OAIProvider" priority="2">
<tr>
<td class="itemtype">OAI Provider:</td>
<td class="itemval"><a href="{text()}"><xsl:value-of select="text()"/></a></td>
</tr>
</xsl:template>

<xsl:template match="ma:riskRank" priority="2">
<tr>
<td class="itemtype">Risk Rank:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="ma:plugin" priority="2">
<tr>
<td class="itemtype">LOCKSS Plugin:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

<xsl:template match="ma:riskFactors" priority="2">
<tr>
<td class="itemtype">Risk Factors:</td>
<td class="itemval"><xsl:value-of select="text()"/></td>
</tr>
</xsl:template>

</xsl:stylesheet>
