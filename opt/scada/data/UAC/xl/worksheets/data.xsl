<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>
 
<xsl:template match="sheetData">
  <xsl:apply-templates select="row"/>
</xsl:template>
 
<xsl:template match="row">
  <xsl:for-each select="*">
   <xsl:value-of select="'INSERT INTO cell_data (cell,style,type,value) VALUES (|'"/>
   <xsl:value-of select="@r"/> <!-- cell identifier -->
   <xsl:value-of select="'|,|'"/>
   <xsl:value-of select="@s"/> <!-- format -->
   <xsl:value-of select="'|,|'"/>
   <xsl:value-of select="@t"/> <!-- data type --> 
   <xsl:value-of select="'|,|'"/>
   <xsl:value-of select="v"/> <!-- the calculated value -->
   <xsl:value-of select="'|);'"/>
   <xsl:if test="position() != last()">
    <!-- <xsl:value-of select="');'"/> -->
    <xsl:text>&#10;</xsl:text>
   </xsl:if>
  </xsl:for-each>
  <xsl:text>&#10;</xsl:text>
</xsl:template>
 
</xsl:stylesheet>
