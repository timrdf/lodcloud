#!/bin/bash
#
#3> <> a conversion:ConversionTrigger; # Could also be conversion:Idempotent;
#3>    prov:specializationOf <https://github.com/timrdf/lodcloud/blob/master/data/source/us/lodcloud-wave-of-arrivals/version/2014-Apr-24/convert.sh>;
#3>    foaf:name    "convert.sh";
#3>    rdfs:seeAlso <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Triggers#wiki-3-computation-triggers>;
#3> .
#

me='https://github.com/timrdf/lodcloud/blob/master/data/source/us/lodcloud-wave-of-arrivals/version/2014-Apr-24/manual/aggregate.xsl'
mkdir -p automatic 
for portion in lodcloud-group lod-tag; do
   echo automatic/$portion.ttl
   saxon.sh manual/aggregate.xsl xml csv -v `cr-sdv.sh --attribute-value` "cr-portion-id=$portion" -in source/$portion.rq.xml > automatic/$portion.ttl

   justify.sh source/lodcloud-group.rq.xml automatic/lodcloud-group.ttl $me
   void-triples.sh automatic/$portion.ttl
done
