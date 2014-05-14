#!/bin/bash

for dataDump in `cat manual/dataDump.csv | randomize-line-order.py`; do
   echo $dataDump
   dataDumpMD5=`md5.sh -qs "$dataDump"`
   if [[ -n "$dataDumpMD5" ]]; then
      if [[ ! -e source/$dataDumpMD5 ]]; then
         echo "$dataDump"                         > source/$dataDumpMD5.url
         echo "curl -L -H 'Accept-Encoding: gzip,deflate'  $dataDump  > source/$dataDumpMD5"
               curl -L -H 'Accept-Encoding: gzip,deflate' "$dataDump" > source/$dataDumpMD5
      fi
   else
      echo "ERROR: $dataDump had md5 $dataDumpMD5"
   fi
done
