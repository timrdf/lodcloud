#3> <> rdfs:seeAlso <https://github.com/timrdf/DataFAQs/wiki/DATAFAQS-environment-variables> .

# Local settings
export DATAFAQS_HOME=${DATAFAQS_HOME:-"/opt/DataFAQs"}
export PATH=$PATH`$DATAFAQS_HOME/bin/df-situate-paths.sh`
export DATAFAQS_LOG_DIR="`pwd`/log"

# Deployment settings:
export DATAFAQS_BASE_URI='http://aquarius.tw.rpi.edu/projects/datafaqs' # No ending slash
export DATAFAQS_PROVENANCE_CODE_RAW_BASE='https://github.com/timrdf/DataFAQs/blob/master' # No ending slash
export DATAFAQS_PROVENANCE_CODE_PAGE_BASE='https://raw.github.com/timrdf/DataFAQs/master' # No ending slash

# Publishing:
export DATAFAQS_PUBLISH_THROUGHOUT_EPOCH="false"
export DATAFAQS_PUBLISH_METADATA_GRAPH_NAME="http://www.w3.org/ns/sparql-service-description#NamedGraph"

# If using TDB:
export DATAFAQS_PUBLISH_TDB="false"
export DATAFAQS_PUBLISH_TDB_DIR="`pwd`/tdb"
export TDBROOT="/opt/tdb/TDB-0.8.10"
if [ ! `which tdbloader` ]; then
   export PATH=$PATH":$TDBROOT/bin"
fi

# If using Virtuoso:
export DATAFAQS_PUBLISH_VIRTUOSO='false'
export CSV2RDF4LOD_CONVERT_DATA_ROOT="`pwd`"
export CSV2RDF4LOD_PUBLISH_VIRTUOSO_HOME='/opt/virtuoso'
export CSV2RDF4LOD_PUBLISH_VIRTUOSO_ISQL_PATH='' # defaults to guess
export CSV2RDF4LOD_PUBLISH_VIRTUOSO_PORT=1111
export CSV2RDF4LOD_PUBLISH_VIRTUOSO_USERNAME='dba'
export CSV2RDF4LOD_PUBLISH_VIRTUOSO_PASSWORD='your-virtuoso-password'

# Local software dependencies: 
export CSV2RDF4LOD_HOME=${CSV2RDF4LOD_HOME:-"/opt/csv2rdf4lod-automation"}
export PATH=$PATH`$CSV2RDF4LOD_HOME/bin/util/cr-situate-paths.sh`
