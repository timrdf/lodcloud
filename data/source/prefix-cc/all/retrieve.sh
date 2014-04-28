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

pushd `dirname $0` &> /dev/null
   version=`date +%Y-%b-%d`
   log=`date +%Y-%b-%dT%H%M`.log
   echo $version

   if [ ! -e version/$version/source ]; then
      mkdir -p version/$version/source
      mkdir -p version/$version/doc

      pushd version/$version/source &> /dev/null
         #pcurl.sh http://prefix.cc/popular/all.file.vann
         #pcurl.sh http://prefix.cc/popular/all.file.csv
         for url in 'http://prefix.cc/popular/all.file.vann' \
                    'http://prefix.cc/popular/all.file.csv'; do
            curl -LO $url                                                     
            justify.sh $url `basename $url` 'http://dbpedia.org/resource/CURL'
         done
         grep 'foaf' all.file.csv
         success=$?
         if [[ "$success" -eq 0 ]]; then
            echo SUCCESS! $success
         else  
            echo fail: $success
         fi
      popd  &> /dev/null
      
      #mkdir publish/all.file.vann.tdb
      #tdbloader --loc=publish/all.file.vann.tdb/ --graph=http://prefix.cc/popular/all.file.vann source/all.file.vann
      #java edu.rpi.tw.string.pmm.DefaultPrefixMappings | awk 'BEGIN{print "@prefix foaf: <http://xmlns.com/foaf/0.1/> .\n@prefix vann: <http://purl.org/vocab/vann/> .\n"} {printf("<> foaf:topic [ vann:preferredNamespacePrefix \"%s\"; vann:preferredNamespaceUri \"%s\" ] .\n",$1,$3)}'
      #tdbloader --loc=publish/all.file.vann.tdb --graph=java:edu.rpi.tw.string.pmm.DefaultPrefixMappings b.ttl
      #tdbquery --loc=publish/all.file.vann.tdb --query=../../../not-in-prefix-cc.rq


      #java edu.rpi.tw.string.pmm.DefaultPrefixMappings | awk '{print $3,":",$1}' | sort -u > manual/edu.rpi.tw.string.pmm.DefaultPrefixMappings.txt
      #tdbquery --loc=publish/all.file.vann.tdb --query=../../../prefix-cc-defs.rq | sed -e 's/|//g' -e 's/"//g' | grep "http" | awk '{print $1,":",$2}' > manual/all.file.vann.tdb.txt
      #diff -y -W 277 manual/all.file.vann.tdb.txt manual/edu.rpi.tw.string.pmm.DefaultPrefixMappings.txt > manual/diff.txt
      #rm -rf publish/all.file.vann.tdb

      if [[ "$success" -ne 0 && -n "$version" && -d version/$version ]]; then
         echo cleaning up source
         rm -rf version/$version/source
      fi
   else
      echo "version/$version exists, skipping."
   fi

popd # &> /dev/null
