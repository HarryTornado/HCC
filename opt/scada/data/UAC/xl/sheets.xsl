<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>
<xsl:template match="sheets">
  <xsl:apply-templates select="sheet"/>
</xsl:template>
<xsl:template match="sheet">
    INSERT INTO sheets(name,ordinal,rid) VALUES ('<xsl:value-of select="translate(@name,&quot;'&quot;,&quot;&quot;)"/>',<xsl:value-of select="@sheetId"/>,<xsl:value-of select="@rid"/>); 
</xsl:template>
</xsl:stylesheet>
