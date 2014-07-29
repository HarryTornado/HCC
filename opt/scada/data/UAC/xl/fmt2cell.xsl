<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>
<xsl:template match="cellXfs">
  <xsl:apply-templates select="xf"/>
</xsl:template>
<xsl:template match="xf">
    INSERT INTO fmt2cell_data(numfmtid) VALUES ('<xsl:value-of select="@numFmtId"/>'); 
</xsl:template>
</xsl:stylesheet>
