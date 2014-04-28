#!/bin/bash
#
#3> <> a conversion:PublicationTrigger; # Could also be conversion:Idempotent;
#3>    foaf:name    "publish.sh";
#3>    rdfs:seeAlso <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Triggers#wiki-4-publication-triggers>;
#3> .
#

aggregate-source-rdf.sh source/*.xml source/*.ttl \
                        manual/*.xsl manual/*.rq  \
                        automatic/*.ttl

