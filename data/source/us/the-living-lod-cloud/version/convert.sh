#!/bin/bash
#
#3> <> a conversion:ConversionTrigger; # Could also be conversion:Idempotent;
#3>    foaf:name    "convert.sh";
#3>    rdfs:seeAlso <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Triggers#wiki-3-computation-triggers>;
#3> .
#

grddl_local='../../src/svg.xsl'
grddl_local='../../src/svg.xsl.has-since-been-updated-2016-Jul-24'
previous_diagram_local='../../src/lod-cloud_colored.svg'
previous_diagram_local='../../src/lod-cloud_2014-08-30_colored.svg'
ttl="`basename $previous_diagram_local`.ttl"
saxon.sh $grddl_local svg ttl $previous_diagram_local | sed 's/thedatahub.org/datahub.io/g' > automatic/$ttl
grddl='https://github.com/timrdf/vsr/blob/master/src/xsl/grddl/svg.xsl'
justify.sh $previous_diagram_local automatic/$ttl $grddl

vsr2grf.sh linksets graffle -w -od automatic source/lodcloud-diagram.rq.rdf

rdf2nt.sh source/'lodcloud-diagram.rq.rdf' automatic/$ttl > automatic/'the-living-lod-cloud.nt'
vsr2grf.sh linksets graffle -w automatic/'the-living-lod-cloud.nt'
#can't b/c two inputs: justify.sh source/'lod-cloud_colored.svg' automatic/'lod-cloud_colored.svg.ttl' $grddl


#rdf2nt.sh source/lodcloud-diagram.rq.rdf automatic/lod-cloud_colored.svg.ttl source/answered-in-survey.rq.rdf > manual/the-living-lod-cloud-with-answers.nt
# vsr2grf.sh linksets graffle -w manual/the-living-lod-cloud-with-answers.nt
