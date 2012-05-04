<?xml version="1.0" encoding="UTF-8" ?>
	<!--
		untitled Created by Bill Anderson on 2010-01-05. Copyright (c) 2010
		__MyCompanyName__. All rights reserved.
	-->

<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output encoding="UTF-8" indent="yes" method="xml" />

	<xsl:template match="/">
		<p>
			<xsl:for-each select="ns1:OAI-PMH/ns1:ListIdentifiers/ns1:header"
				xmlns:ns1="http://www.openarchives.org/OAI/2.0/">
				<xsl:element name="a">
					<xsl:attribute name="href"><xsl:apply-templates
						select="ns1:identifier" /></xsl:attribute>
					<xsl:apply-templates select="ns1:identifier" />
				</xsl:element>
				<br />
			</xsl:for-each>
		</p>
	</xsl:template>

	<xsl:template match="ns1:identifier" xmlns:ns1="http://www.openarchives.org/OAI/2.0/">
		<!--
			<xsl:value-of select="substring(.,5,19)"/>/handle/<xsl:value-of
			select="substring(.,25)"/>?mode=full&amp;submit_simple=Show+full+item+record
		-->
		<xsl:value-of select="substring(.,5,26)" />
		/handle/
		<xsl:value-of select="substring(.,32)" />?mode=full&amp;submit_simple=Show+full+item+record
	</xsl:template>

</xsl:stylesheet>
