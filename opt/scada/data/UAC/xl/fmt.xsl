<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>
<xsl:template match="numFmts">
  <xsl:apply-templates select="numFmt"/>
</xsl:template>
<xsl:template match="numFmt">
    INSERT INTO fmt_data(numfmtid,formatcode) VALUES ('<xsl:value-of select="@numFmtId"/>','<xsl:value-of select="@formatCode"/>'); 
</xsl:template>
</xsl:stylesheet>
