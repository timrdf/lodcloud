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

if [[ "$1" == "clean" ]]; then
   rm manual/classes.csv manual/properties.csv
   exit
fi

echo "Term,Term Type,Count,Query,Query DateTime" > manual/classes.csv
echo "Term,Term Type,Count,Query,Query DateTime" > manual/properties.csv

for rq in `find manual -name "*.rq"`; do
   rq_base=`basename $rq`
   echo $rq

   term=`cat $rq | sed 's/^.*<//;s/>.*$//'`                                                               # http://www.w3.org/ns/prov#Entity
   termtype=`basename $rq | sed 's/_.*$//'`                                                               # class
   count=`tail -1 source/$rq_base.csv`                                                                    # 33
   query=`grep prov:wasQuotedFrom source/$rq_base.csv.prov.ttl | awk '{print $2}' | sed 's/<//;s/>.*$//'` # http://lod.openlinksw.com/sparql?query=select%20coun...
   date=`grep dcterms:date source/$rq_base.csv.prov.ttl | awk '{print $2}' | sed 's/^"//;s/".*$//'`       # 2014-02-20T16:43:35+00:00
   echo "  $term"
   echo "  $termtype"
   echo "  $count"
   echo "  $query"
   echo "  $date"
   if [[ "$termtype" == "class" ]]; then
      echo "$term,$termtype,$count,$query,$date" >> manual/classes.csv
   elif [[ "$termtype" == "property" ]]; then
      echo "$term,$termtype,$count,$query,$date" >> manual/properties.csv
   fi
done
