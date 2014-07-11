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

api='https://access.alchemyapi.com'
api='http://access.alchemyapi.com'
if [[ -n "$X_ALCHEMY_API_Key" ]]; then
   mkdir -p source
   #curl -d '' "$api/calls/text/TextGetRankedConcepts?apikey=$X_ALCHEMY_API_Key&text=The%20City%20by%20the%20Bay%3b%20Fog%20City%3b%20San%20Fran%3b%20Frisco%3b%20The%20City%20that%20Knows%20How%20%3b%20Baghdad%20by%20the%20Bay%20%3b%20The%20Paris%20of%20the%20West&url=http%3A%2F%2Flive.dbpedia.org%2Fpage%2FSan_Francisco&outputMode=rdf" > source/san-francisco-nicknames.rdf
   # ^^ gives &url param \\// does not give &url parameter -- a difference?
   curl -d '' "$api/calls/text/TextGetRankedConcepts?apikey=$X_ALCHEMY_API_Key&text=The%20City%20by%20the%20Bay%3b%20Fog%20City%3b%20San%20Fran%3b%20Frisco%3b%20The%20City%20that%20Knows%20How%20%3b%20Baghdad%20by%20the%20Bay%20%3b%20The%20Paris%20of%20the%20West&outputMode=rdf" > source/san-francisco-nicknames-nocheating.rdf
else
   echo "ERROR: need to set envvar X_ALCHEMY_API_Key; see http://www.alchemyapi.com/api/calling-the-api/"
fi
