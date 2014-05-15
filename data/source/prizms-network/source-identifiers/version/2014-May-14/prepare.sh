#!/bin/bash
#
#3> <> a conversion:PreparationTrigger; # Could also be conversion:Idempotent;
#3>    foaf:name "prepare.sh";
#3>    rdfs:seeAlso
#3>     <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Automated-creation-of-a-new-Versioned-Dataset>,
#3>     <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Triggers>,
#3>     <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-trigger>,
#3>     <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-cockpit>;
#3> .
#
# This script is responsible for processing files in source/ and storing their modified forms
# as files in the manual/ directory. These modified files should be ready for conversion.
# 
# This script is also responsible for constructing the conversion trigger
#   (e.g., with cr-create-conversion-trigger.sh -w manual/*.csv)
#
# When this script resides in a cr:directory-of-versions directory,
# (e.g. source/datahub-io/corpwatch/version)
# it is invoked by retrieve.sh (or cr-retrieve.sh).
#   (see https://github.com/timrdf/csv2rdf4lod-automation/wiki/Directory-Conventions)
#
# When this script is invoked, the conversion cockpit is the current working directory.
#

mkdir -p intermediate
csv='intermediate/ids-counts.csv'
echo $csv
echo "endpoint,num source IDs,num dataset IDs,num version IDs" > $csv
for endpoint in `find source -mindepth 1 -maxdepth 1 -type d`; do
   s=`wc -l $endpoint/source-identifiers.rq.sparql.csv | awk '{print $1}'`
   d=`wc -l $endpoint/dataset-identifiers.rq.sparql.csv | awk '{print $1}'`
   v=`wc -l $endpoint/version-identifiers.rq.sparql.csv | awk '{print $1}'`
   echo `basename $endpoint`,$s,$d,$v >> $csv
done
cat $csv | sort --field-separator=',' -n -r --key=2,4 > $csv.tmp && mv $csv.tmp $csv
