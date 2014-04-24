<xsl:transform version="2.0" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:rq="http://www.w3.org/2005/sparql-results#"
   exclude-result-prefixes="">
<xsl:output method="text"/>

<xsl:param name="cr-base-uri"   select="'http://my.com'"/>
<xsl:param name="cr-source-id"  select="'epa-gov'"/>
<xsl:param name="cr-dataset-id" select="'some-dataset'"/>
<xsl:param name="cr-version-id" select="'latest'"/>
<xsl:param name="cr-portion-id" select="''"/>

<xsl:variable name="abstract" select="concat($cr-base-uri,'/source/',$cr-source-id,'/dataset/',$cr-dataset-id)"/>

<xsl:variable name="sdv"  select="concat($cr-base-uri,'/source/', $cr-source-id,'/dataset/',$cr-dataset-id,'/version/',$cr-version-id)"/>
<xsl:variable name="sdvp" select="concat($cr-base-uri,'/source/', $cr-source-id,'/dataset/',$cr-dataset-id,'/version/',$cr-version-id, 
                                         if($cr-portion-id) then concat('/',$cr-portion-id) else '')"/>

<!--
<sparql xmlns="http://www.w3.org/2005/sparql-results#"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">
 <head>
  <variable name="dataset"/>
  <variable name="created"/>
 </head>
 <results distinct="false" ordered="true">
  <result>
   <binding name="dataset"><uri>http://datahub.io/dataset/freebase</uri></binding>
   <binding name="created"><literal>2007-11-26T09:59:38</literal></binding>
  </result>
  <result>
   <binding name="dataset"><uri>http://datahub.io/dataset/gemet</uri></binding>
   <binding name="created"><literal>2008-03-12T22:54:58</literal></binding>
  </result>
-->

<!-- http://stackoverflow.com/questions/1384802/java-how-to-indent-xml-generated-by-transformer -->

<!--
                       group-by="substring(rq:binding[@name='created']/rq:literal,1,4)">
-->

<xsl:variable name="prefixes">
<xsl:text><![CDATA[
@prefix prov:    <http://www.w3.org/ns/prov#>.
@prefix dcterms: <http://purl.org/dc/terms/>.
@prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#>.
@prefix foaf:    <http://xmlns.com/foaf/0.1/>.
@prefix pext:    <http://www.ontotext.com/proton/protonext#> .
@prefix sio:     <http://semanticscience.org/resource/>.
@prefix qb:      <http://purl.org/linked-data/cube#>.
]]></xsl:text>
</xsl:variable>

<xsl:template match="/">
   <xsl:value-of select="concat($prefixes,'@base ',$LT,$abstract,'/vocab/',$GT,'.',$NL,$NL)"/>
   <xsl:for-each-group   select="rq:sparql/rq:results/rq:result" 
                       group-by="year-from-dateTime(xs:dateTime(rq:binding[@name='created']))">
      <xsl:variable name="year" select="current-grouping-key()"/>
      <xsl:for-each-group select="current-group()"
                    group-by="month-from-dateTime(xs:dateTime(rq:binding[@name='created']))">
         <xsl:variable name="month" select="current-grouping-key()"/>
         <xsl:value-of select="concat($LT,$sdvp,'/',$year,'/',$month,$GT,' a qb:Observation;',$NL,
                                      '   ',$LT,'group',$GT,' ',$LT,$sdv,'/',$cr-portion-id,$GT,';',$NL,
                                      '   ',$LT,'year',$GT,' ',$year,';',$NL,
                                      '   ',$LT,'month',$GT,' ',$month,';',$NL,
                                      '   sio:count ',count(current-group()),';',$NL)"/>
         <xsl:for-each select="current-group()">
            <xsl:value-of select="concat('   sio:has-member ',$LT,rq:binding[@name='dataset']/rq:uri,$GT,';',$NL)"/>
         </xsl:for-each>
         <xsl:value-of select="concat('.',$NL)"/>
      </xsl:for-each-group>
   </xsl:for-each-group>
</xsl:template>

<xsl:template match="@*|node()">
  <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<!--xsl:template match="text()">
   <xsl:value-of select="normalize-space(.)"/>
</xsl:template-->

<xsl:variable name="NL" select="'&#xa;'"/>
<xsl:variable name="DQ" select="'&#x22;'"/>
<xsl:variable name="LT">&lt;</xsl:variable>
<xsl:variable name="GT">&gt;</xsl:variable>

</xsl:transform>
