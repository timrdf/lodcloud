#!/bin/bash
#
#3> <> a conversion:PublicationTrigger; # Could also be conversion:Idempotent;
#3>    foaf:name    "publish.sh";
#3>    rdfs:seeAlso <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Triggers#wiki-4-publication-triggers>;
#3> .
#

# In cases where many files need to be aggregated (and would exceed num argument limitations)
# aggregate='automatic/all.nt'
#mkdir -p `dirname $aggregate`
#echo "find automatic -name "*.json.ttl" | xargs -n 1 -I ttl serdi -i turtle -o ntriples ttl > $aggregate"
#      find automatic -name "*.json.ttl" | xargs -n 1 -I ttl serdi -i turtle -o ntriples ttl > $aggregate

cr-publish.sh `find -L automatic -name "*colored.svg.ttl"` --no-compress --no-turtle --ntriples
