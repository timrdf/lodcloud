#!/bin/bash
#
#3> <> a conversion:ConversionTrigger; # Could also be conversion:Idempotent;
#3>    foaf:name    "convert.sh";
#3>    rdfs:seeAlso <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Triggers#wiki-3-computation-triggers>;
#3> .
#

if [[ "$1" == 'clean' ]]; then
   if [[ "$2" == 'all' ]]; then
      find -L automatic -name "*colored.svg.ttl" -print0 | \
         xargs -0 -n 1 -P ${CSV2RDF4LOD_CONCURRENCY:-1} -I converted rm converted
   else
      $0 clean 'all'
   fi
fi

if [[ -e "$1" ]]; then
   while [[ $# -gt 0 ]]; do
      mundane="$1" && shift
      ttl="automatic/${mundane#source/}.ttl"
      echo $ttl
      if [[ ! -e $ttl || $mundane -nt $ttl ]]; then
         mkdir -p `dirname $ttl`
         echo "@base <`cr-dataset-uri.sh --uri`/> ."  > $ttl
         saxon.sh ../../src/svg.xsl svg ttl $mundane >> $ttl
      fi
   done
   exit
else
   # https://github.com/timrdf/csv2rdf4lod-automation/wiki/Triggers#parallelize-with-recursive-calls-via-xargs
   find -L source -name "*colored.svg" -print0 | \
      xargs -0 -n 1 -P ${CSV2RDF4LOD_CONCURRENCY:-1} -I mundane $0 mundane
fi
