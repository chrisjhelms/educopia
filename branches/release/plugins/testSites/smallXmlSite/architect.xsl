<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
  <html>
  <body>
    <h2>
        <xsl:value-of select="architect/name" />
    </h2>
    <table> 
    <tr><td> 
       <img src="../images/{architect/image}" 
            width="200px" border="0" 
            alt="Portrait of {architect/name}" />
    </td>
    <td valign="top" vspan="10px"> </td>
    <td valign="top"> 
       <p> Nationality <xsl:value-of select="architect/nationality" /> </p> 
       <p> Born <xsl:value-of select="architect/birthdate" /> in <xsl:value-of select="architect/birthplace" /> </p> 
       <p> Died <xsl:value-of select="architect/deathdate"/>  in <xsl:value-of select="architect/deathplace" /> </p> 
    </td>
    </tr>
</table>


<xsl:for-each select="architect/bio/p"> 
    <p> 
    <xsl:value-of select="." />
    </p> 
</xsl:for-each>


<p> 
<a href="../index.html">Return Home</a> 
</p> 

</body>

</html>

</xsl:template>
</xsl:stylesheet>
