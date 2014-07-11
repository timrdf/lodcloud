<!--
#3> <> dcterms:provenance "git-ec2/******/data/source/cisco-com/asset-alchemyapi/src";
#3> .


TODO: qualify each dcterms:references relation, 
      do NOT assert the unqualified form, 
      and attribute the reference to AlchemyAPI.
-->
<xsl:transform version="2.0" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:aapi="http://rdf.alchemyapi.com/rdf/v1/s/aapi-schema#"
   xmlns:owl="http://www.w3.org/2002/07/owl#"
   xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
   xml:base="http://rdf.alchemyapi.com/rdf/v1/r/response.rdf"
   exclude-result-prefixes="">
<xsl:output method="text"/>

<!--
A versioned dataset URI,
e.g. http://some.com/source/S/dataset/asset-alchemyapi/version/2013-Aug-21
-->
<xsl:param name="base-uri" select="''"/>

<!--
An abstract dataset URI,
e.g. http://some.com/source/S/dataset/asset-alchemyapi
-->
<xsl:param name="abstract-uri" select="substring-before($base-uri,'/version/')"/>

<xsl:template match="/">
   <xsl:value-of select="concat(
                                '@prefix rdfs:    &lt;http://www.w3.org/2000/01/rdf-schema#&gt;.',$NL,
                                '@prefix owl:     &lt;http://www.w3.org/2002/07/owl#&gt;.',$NL,
                                '@prefix foaf:    &lt;http://xmlns.com/foaf/0.1/&gt;.',$NL,
                                '@prefix dcterms: &lt;http://purl.org/dc/terms/&gt;.',$NL,
                                '@prefix schema:  &lt;http://schema.org/&gt;.',$NL,
                                '@prefix prov:    &lt;http://www.w3.org/ns/prov#&gt;.',$NL,
                                '@prefix sio:     &lt;http://semanticscience.org/resource/&gt;.',$NL,
                                '@prefix aapi:    &lt;http://rdf.alchemyapi.com/rdf/v1/s/aapi-schema#&gt;.',$NL,
                                '@prefix twaapi:  &lt;http://purl.org/twc/vocab/aapi-schema#&gt;.',$NL,
                                if ($abstract-uri) then concat('@base            &lt;',$abstract-uri,'/&gt; .',$NL) else '',
                               $NL)"/>
      <xsl:apply-templates/>
</xsl:template>

<xsl:template match="@*|node()">
   <xsl:apply-templates/>
</xsl:template>

<!-- 
   aapi:DocInfo
   see https://github.com/timrdf/prizms/wiki/AlchemyAPI#categoryextraction
-->
<xsl:template match="rdf:RDF/rdf:Description[rdf:type[@rdf:resource='http://rdf.alchemyapi.com/rdf/v1/s/aapi-schema#DocInfo']]">
   <!-- and aapi:ResultStatus and aapi:Usage and aapi:URL and aapi:Language and aapi:DocCateg and aapi:DocCategScore]"-->
   <xsl:value-of select="concat($LT,'doc/',@rdf:ID,$GT,$NL,
                               '   owl:sameAs &lt;http://rdf.alchemyapi.com/rdf/v1/r/response.rdf#',@rdf:ID,'&gt;;',$NL)"/>
   <xsl:apply-templates select="rdf:type | aapi:ResultStatus | aapi:Usage | aapi:URL | aapi:Language | aapi:DocCateg | aapi:DocCategScore" mode="document-info"/>
   <xsl:value-of select="concat('.',$NL)"/>
</xsl:template>

<xsl:template match="rdf:type" mode="document-info">
   <xsl:choose>
      <xsl:when test="@rdf:resource = 'http://rdf.alchemyapi.com/rdf/v1/s/aapi-schema#DocInfo'">
         <xsl:value-of select="concat('   a foaf:Document;',$NL)"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="aapi:ResultStatus" mode="document-info">
</xsl:template>

<xsl:template match="aapi:Usage" mode="document-info">
</xsl:template>

<xsl:template match="aapi:URL" mode="document-info">
   <xsl:value-of select="concat('   prov:specializationOf &lt;',.,'&gt;;',$NL)"/>
</xsl:template>

<xsl:template match="aapi:Language" mode="document-info">
   <xsl:choose>
      <xsl:when test=". = 'english'">
         <xsl:value-of select="concat('   dcterms:language &lt;http://dbpedia.org/resource/English_language&gt;;',$NL)"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="aapi:DocCateg" mode="document-info">
   <xsl:value-of select="concat('   schema:category ',$LT,'category/',.,$GT,';',$NL)"/>
</xsl:template>

<xsl:template match="aapi:DocCategScore" mode="document-info">
   <xsl:if test="string-length(.)">
      <xsl:value-of select="concat('   twaapi:categoryScore ',.,';',$NL)"/>
   </xsl:if>
</xsl:template>



<!--
   aapi:ConceptOccurrence
   see https://github.com/timrdf/prizms/wiki/AlchemyAPI#concepttagging
-->
<xsl:template match="rdf:RDF/rdf:Description[rdf:type[@rdf:resource='http://rdf.alchemyapi.com/rdf/v1/s/aapi-schema#ConceptOccurrence']]">
   <xsl:value-of select="concat($LT,'doc/',@rdf:ID,$GT,$NL,
                                '   owl:sameAs &lt;http://rdf.alchemyapi.com/rdf/v1/r/response.rdf#',@rdf:ID,'&gt;;',$NL)"/>
   <!-- these have the same interpretation regardless of where they appear -->
   <xsl:apply-templates select="aapi:Doc | owl:sameAs"/>
   <xsl:apply-templates select="aapi:Relevance | aapi:Name" mode="concept-tagging"/>
   <xsl:value-of select="concat('.',$NL)"/>
</xsl:template>

<xsl:template match="aapi:Doc">
   <xsl:value-of select="concat('   dcterms:isReferencedBy ',$LT,'doc/',.,$GT,';',$NL)"/>
</xsl:template>

<xsl:template match="aapi:Relevance" mode="concept-tagging">
   <xsl:if test="string-length(.)">
      <xsl:value-of select="concat('   twaapi:relevance ',.,';',$NL)"/>
   </xsl:if>
</xsl:template>

<xsl:template match="aapi:Name" mode="concept-tagging">
   <xsl:if test="string-length(.)">
      <xsl:value-of select="concat('   rdfs:label ',$DQ,.,$DQ,';',$NL)"/>
   </xsl:if>
</xsl:template>

<xsl:template match="owl:sameAs">
   <xsl:value-of select="concat('   owl:sameAs ',$LT,@rdf:resource,$GT,';',$NL)"/>
</xsl:template>

<!--
   aapi:EntityOccurrences
   see https://github.com/timrdf/prizms/wiki/AlchemyAPI#rankednamedentities
-->
<xsl:template match="rdf:RDF/rdf:Description[rdf:type[@rdf:resource='http://rdf.alchemyapi.com/rdf/v1/s/aapi-schema#EntityOccurrences']]">
   <xsl:value-of select="concat($LT,'doc/',@rdf:ID,$GT,$NL,
                                '   owl:sameAs &lt;http://rdf.alchemyapi.com/rdf/v1/r/response.rdf#',@rdf:ID,'&gt;;',$NL)"/>
   <!-- these have the same interpretation regardless of where they appear -->
   <xsl:apply-templates select="aapi:Doc |
                                aapi:Disambiguation/rdf:Description[rdf:type/@rdf:resource='http://rdf.alchemyapi.com/rdf/v1/s/aapi-schema#Disambiguation']/
                                                                                                                                     (aapi:Doc | owl:sameAs)"/>
   <!-- reuse the interpretations of previous types -->
   <xsl:apply-templates select="aapi:Relevance | aapi:Name" mode="concept-tagging"/>
   <xsl:apply-templates select="aapi:EntityType | 
                                aapi:NumOccurs  | 
                                aapi:Disambiguation/rdf:Description[rdf:type/@rdf:resource='http://rdf.alchemyapi.com/rdf/v1/s/aapi-schema#Disambiguation']/
                                                                                                            (aapi:EntityGUID | aapi:ResolvedName | aapi:URL)" 
                        mode="ranked-named-entities"/>
   <xsl:value-of select="concat('.',$NL)"/>
</xsl:template>

<xsl:template match="aapi:EntityType" mode="ranked-named-entities">
   <xsl:value-of select="concat('   a ',$LT,'type/',.,$GT,';',$NL)"/>
</xsl:template>

<xsl:template match="aapi:NumOccurs" mode="ranked-named-entities">
   <xsl:if test="string-length(.)">
      <xsl:value-of select="concat('   sio:count ',.,';',$NL)"/>
   </xsl:if>
</xsl:template>

<xsl:template match="aapi:EntityGUID" mode="ranked-named-entities">
   <xsl:value-of select="concat('   prov:specializationOf ',$LT,'entity/',.,$GT,';',$NL)"/>
</xsl:template>

<xsl:template match="aapi:ResolvedName" mode="ranked-named-entities">
   <xsl:if test="string-length(.)">
      <xsl:value-of select="concat('   twaapi:resolvedName ',$DQ,.,$DQ,';',$NL)"/>
   </xsl:if>
</xsl:template>

<xsl:template match="aapi:URL" mode="ranked-named-entities">
   <xsl:value-of select="concat('   foaf:page &lt;',.,'&gt;;',$NL)"/>
</xsl:template>

<!--
   aapi:EntityOccurrences
   see https://github.com/timrdf/prizms/wiki/AlchemyAPI#rankednamedentities
-->
<xsl:template match="rdf:RDF/rdf:Description[rdf:type[@rdf:resource='http://rdf.alchemyapi.com/rdf/v1/s/aapi-schema#RelationOccurrence']]">
</xsl:template>

<xsl:variable name="NL" select="'&#xa;'"/>
<xsl:variable name="DQ" select="'&#x22;'"/>
<xsl:variable name="LT" select="'&#x3c;'"/>
<xsl:variable name="GT" select="'&#x3e;'"/>

</xsl:transform>
