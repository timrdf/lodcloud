#!/bin/bash
#
# run publish/bin/virtuoso-load-datahub-io-lodcloud-group-2014-07-04.sh
# from source/datahub-io/lodcloud-group/version/2014-07-04/
#
# graph was  during conversion
# metadataset graph was auto during conversion
#
#        $CSV2RDF4LOD_PUBLISH_METADATASET_GRAPH_NAME            # <---- Loads into this with param --as-metadatset
#
#
#                               AbstractDataset                  # <---- Loads into this with param --abstract
#                     (http://.org/source/sss/dataset/ddd)                                                         
#                                     |                   \                                                        
# Loads into this by default -> VersionedDataset           meta  # <---- Loads into this with param --meta
#              (http://.org/source/sss/dataset/ddd/version/vvv)                                                    
#                                     |                                                                            
#                                LayerDataset                                                                      
#                                   /    \                                                                         
# Never loads into this ----> [table]   DatasetSample            # <---- Loads into this with param --sample
#
# See https://github.com/timrdf/csv2rdf4lod-automation/wiki/Aggregating-subsets-of-converted-datasets
# See https://github.com/timrdf/csv2rdf4lod-automation/wiki/Named-graph-organization

wiki='https://github.com/timrdf/csv2rdf4lod-automation/wiki'
CSV2RDF4LOD_HOME=${CSV2RDF4LOD_HOME:?"not set; source csv2rdf4lod/source-me.sh or see $wiki/CSV2RDF4LOD-not-set"}
CSV2RDF4LOD_BASE_URI=${CSV2RDF4LOD_BASE_URI:?"not set; source csv2rdf4lod/source-me.sh or see $wiki/CSV2RDF4LOD-not-set"}

see="/CSV2RDF4LOD-environment-variables-%28considerations-for-a-distributed-workflow%29"
if [ `is-pwd-a.sh cr:dev` == 'yes' ]; then
   echo "Refusing to publish; see 'cr:dev and refusing to publish' at"
   echo "  "
   exit 1
fi
if [ -e 'publish/bin/ln-to-www-root-datahub-io-lodcloud-group-2014-07-04.sh' ]; then
   # Make sure that the file we will load from the web is published
   publish/bin/ln-to-www-root-datahub-io-lodcloud-group-2014-07-04.sh
fi

base=${CSV2RDF4LOD_BASE_URI_OVERRIDE:-$CSV2RDF4LOD_BASE_URI}
graph=`cat publish/datahub-io-lodcloud-group-2014-07-04.sd_name`
metaGraph="$graph"
if [ "$1" == "--sample" ]; then
   exit 1
elif [[ "$1" == "--meta" && -e '' ]]; then
   metaURL="$base/source/datahub-io/file/lodcloud-group/version/2014-07-04/conversion/datahub-io-lodcloud-group-2014-07-04.void.ttl"
   metaGraph="$base"/vocab/Dataset
   echo pvload.sh $metaURL -ng $metaGraph
   ${CSV2RDF4LOD_HOME}/bin/util/pvload.sh $metaURL -ng $metaGraph
   exit 1
fi

# Change the target graph before continuing to load everything
if [[ "$1" == "--unversioned" || "$1" == "--abstract" ]]; then
   # strip off version
   graph="`echo $graph\ | perl -pe 's|/version/[^/]*$||'`"
   graph="$base/source/datahub-io/dataset/lodcloud-group"
   echo populating abstract named graph \($graph\) instead of versioned named graph.
elif [[ "$1" == "--meta" ]]; then
   metaGraph="$base"/vocab/Dataset
elif [[ "$1" == "--as-metadataset" ]]; then
   graph="${CSV2RDF4LOD_PUBLISH_METADATASET_GRAPH_NAME:-'http://purl.org/twc/vocab/conversion/MetaDataset'}"
   metaGraph="$graph"
elif [[ "$CSV2RDF4LOD_PUBLISH_SPARQL_ENDPOINT_SEPARATE_NG_PROVENANCE" == 'true' ]]; then
   metaGraph=`pvload.sh --prov-graph-name $graph`
elif [ $# -gt 0 ]; then
   echo param not recognized: $1
   echo usage: `basename $0` with no parameters loads versioned dataset
   echo usage: `basename $0` --{sample, meta, abstract}
   exit 1
fi

# Load the metadata, either in the same named graph as the data or into a more global one.
metaURL="$base/source/datahub-io/file/lodcloud-group/version/2014-07-04/conversion/datahub-io-lodcloud-group-2014-07-04.void.ttl"
echo pvload.sh $metaURL -ng $metaGraph
${CSV2RDF4LOD_HOME}/bin/util/pvload.sh $metaURL -ng $metaGraph
if [[ "$1" == "--meta" ]]; then
   exit 1
fi

[[ "$CSV2RDF4LOD_PUBLISH_SPARQL_ENDPOINT_SEPARATE_NG_PROVENANCE" == 'true' ]] && sep='--separate-provenance' || sep=''
function try {
   dump="publish/datahub-io-lodcloud-group-2014-07-04${1}"
   url=$base/source/datahub-io/file/lodcloud-group/version/2014-07-04/conversion/datahub-io-lodcloud-group-2014-07-04${1}
   if [ -e $dump ]; then
      echo pvload.sh $url -ng $graph $sep
      ${CSV2RDF4LOD_HOME}/bin/util/pvload.sh $url -ng $graph $sep
      exit 1
   elif [ -e $dump.gz ]; then
      echo pvload.sh $url.gz -ng $graph $sep
      ${CSV2RDF4LOD_HOME}/bin/util/pvload.sh $url.gz -ng $graph $sep
      exit 1
   fi
}

try .nt
try .ttl
try .rdf

#3> <> prov:wasAttributedTo <http://purl.org/twc/lodcloud/id/csv2rdf4lod/> .
#3> <> prov:generatedAtTime "2014-07-05T05:16:08+00:00"^^xsd:dateTime .
#3> <http://purl.org/twc/lodcloud/id/csv2rdf4lod/> foaf:name "aggregate-source-rdf.sh" .
