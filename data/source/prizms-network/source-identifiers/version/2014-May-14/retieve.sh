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

rq='../../src/source-identifiers.rq'
for endpoint in `cat source/endpoints.csv | grep ^http`; do
   domain=`resource-name.sh --domain-of $endpoint` # e.g. http://healthdata.tw.rpi.edu
   domain=${domain#https://} 
   domain=${domain#http://}                        # e.g. healthdata.tw.rpi.edu
   echo $endpoint $domain

   for id in source dataset version; do
      cache-queries.sh $endpoint -o sparql -q ../../src/$id-identifiers.rq $rq -od source/$domain
      echo source/$domain/$id-identifiers.rq.sparql.csv
      saxon.sh ../../src/bindings.xsl sparql csv source/$domain/$id-identifiers.rq.sparql > source/$domain/$id-identifiers.rq.sparql.csv

      echo "number of distinct $id identifiers:"
      cat source/*/$id*.csv | sort -u  | wc -l

      echo "number of source identifier occurrences:"
      cat source/*/$id*.csv | wc -l

      echo "from number of distinct Prizms nodes:"
      wc -l source/endpoints.csv
   done
done

