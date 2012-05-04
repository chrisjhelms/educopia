<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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

<xsl:template match="*" priority="1">
</xsl:template>

<xsl:template match="/missing" priority="2">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>
	<title>Missing Items</title>
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
	<h1>The Following Descriptive Items Are Missing:</h1>
	<ul>
	<xsl:apply-templates/>
	</ul>
	<hr />
	<a href="index.php">Return To Index</a>
	</body>
	</html>
</xsl:template>

<xsl:template match="item" priority="2">
<li><xsl:value-of select="@title" /></li>
</xsl:template>

<xsl:template match="/valid" priority="2">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>
	<title>Valid</title>
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
	<h1>This Description is Valid</h1>
	<hr />
	<a href="index.php">Return To Index</a>
	</body>
	</html>
</xsl:template>

</xsl:stylesheet>
