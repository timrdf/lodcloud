#!/bin/bash
#
#3> @prefix doap:    <http://usefulinc.com/ns/doap#> .
#3> @prefix dcterms: <http://purl.org/dc/terms/> .
#3> @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
#3> 
#3> <> a conversion:RetrievalTrigger, doap:Project; # Could also be conversion:Idempotent;
#3>    dcterms:description 
#3>      "Script to retrieve and convert a new version of the dataset.";
#3>    rdfs:seeAlso 
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Automated-creation-of-a-new-Versioned-Dataset>,
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/tic-turtle-in-comments>;
#3> .

mkdir -p manual
if [[ ! -e manual/lodcloud-diagram.rq ]]; then
   cp ../../src/lodcloud-diagram.rq manual/lodcloud-diagram.rq
   echo "MANUALLY ADD GRAPH{} to manual/lodcloud-diagram.rq"
   exit
fi
cache-queries.sh ${CSV2RDF4LOD_PUBLISH_SPARQL_ENDPOINT:-'http://lodcloud.tw.rpi.edu/sparql'} -o rdf -q manual/lodcloud-diagram.rq -od source/