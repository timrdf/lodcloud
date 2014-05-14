<xsl:transform version="2.0" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:rq="http://www.w3.org/2005/sparql-results#" 
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   exclude-result-prefixes="">
<xsl:output method="text"/>

<!-- <head>
        <variable name="sourceID"/>
     </head>
     <results distinct="false" ordered="true">
        <result>
           <binding name="sourceID"><literal>bioontology-org</literal></binding>
        </result> -->

<xsl:template match="/">
   <xsl:for-each-group select="//rq:result/rq:binding[@name='sourceID']/rq:literal" group-by="text()">
      <xsl:value-of select="concat(text(),$NL)"/>
   </xsl:for-each-group>
</xsl:template>

<xsl:template match="@*|node()">
  <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:variable name="NL" select="'&#xa;'"/>
<xsl:variable name="DQ" select="'&#x22;'"/>

</xsl:transform>
