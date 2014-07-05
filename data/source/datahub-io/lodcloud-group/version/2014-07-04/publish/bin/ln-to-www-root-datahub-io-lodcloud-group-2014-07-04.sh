#!/bin/bash
#
# run from source/datahub-io/lodcloud-group/version/2014-07-04/
#
# CSV2RDF4LOD_PUBLISH_VARWWW_ROOT
# was 
# 
# when this script was created. 
#
#3> <> prov:wasGeneratedBy [ prov:qualifiedAssociation [ prov:hadPlan <https://raw.github.com/timrdf/csv2rdf4lod-automation/master/bin/aggregate-source-rdf.sh> ] ] .
#3> <https://raw.github.com/timrdf/csv2rdf4lod-automation/master/bin/aggregate-source-rdf.sh> a prov:Plan; foaf:homepage <https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/aggregate-source-rdf.sh> .

CSV2RDF4LOD_PUBLISH_VARWWW_ROOT=${CSV2RDF4LOD_PUBLISH_VARWWW_ROOT:?"not set; source csv2rdf4lod/source-me.sh "}

symbolic=""
pwd=""
if [[ "$1" == "-s" || "$CSV2RDF4LOD_PUBLISH_VARWWW_LINK_TYPE" == "soft" ]]; then
  symbolic="-sf "
  pwd=`pwd`/
  shift
fi

sudo="sudo"
if [[ `whoami` == root ]]; then
   sudo=""
elif [[ "`stat --format=%U "$CSV2RDF4LOD_PUBLISH_VARWWW_ROOT/source"`" == `whoami` ]]; then
   sudo=""
fi

function lnwww {
   publish=""
   if [ "$2" == 'publish' ]; then 
      publish="conversion"
   fi
   wwwfile="$CSV2RDF4LOD_PUBLISH_VARWWW_ROOT/source/datahub-io/file/lodcloud-group/version/2014-07-04/$publish${1#publish}"
   if [ -e "$1" -o "$2" == 'publish' ]; then 
      if [ -e "$wwwfile" ]; then 
         if [[ -n "$sudo" ]]; then
            echo $sudo rm -f "$wwwfile"
         fi
         $sudo rm -f "$wwwfile"
      else
         if [[ -n "$sudo" ]]; then
            echo $sudo mkdir -p `dirname "$wwwfile"`
         fi
         $sudo mkdir -p `dirname "$wwwfile"`
      fi
      echo "  $wwwfile"
      if [[ -n "$sudo" ]]; then
         echo $sudo ln $symbolic "${pwd}$1" "$wwwfile"
      fi
      $sudo ln $symbolic "${pwd}$1" "$wwwfile"
   else
      echo "  -- $1 omitted --"
   fi
}

lnwww publish/datahub-io-lodcloud-group-latest.ttl.gz publish
lnwww publish/datahub-io-lodcloud-group-2014-07-04.ttl.gz publish
lnwww publish/datahub-io-lodcloud-group-2014-07-04.void.ttl publish
