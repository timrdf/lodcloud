#!/bin/bash
#
#3> <> a conversion:ConversionTrigger; # Could also be conversion:Idempotent;
#3>    foaf:name    "convert.sh";
#3>    rdfs:seeAlso <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Triggers#wiki-3-computation-triggers>;
#3> .
#

grddl='https://github.com/timrdf/vsr/blob/master/src/xsl/grddl/svg.xsl'
saxon.sh   source/svg.xsl svg ttl source/lod-cloud_colored.svg | sed 's/thedatahub.org/datahub.io/g' > automatic/lod-cloud_colored.svg.ttl
justify.sh source/svg.xsl automatic/lod-cloud_colored.svg.ttl $grddl

vsr2grf.sh linksets graffle -w -od automatic source/lodcloud-diagram.rq.rdf

rdf2nt.sh source/lodcloud-diagram.rq.rdf automatic/lod-cloud_colored.svg.ttl > automatic/both.nt
vsr2grf.sh linksets graffle -w automatic/both.nt 


#rdf2nt.sh source/lodcloud-diagram.rq.rdf automatic/lod-cloud_colored.svg.ttl source/answered-in-survey.rq.rdf > manual/both-with-answers.nt
# vsr2grf.sh linksets graffle -w manual/both-with-answers.nt
