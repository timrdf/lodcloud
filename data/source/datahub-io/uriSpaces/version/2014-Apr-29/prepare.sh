#!/bin/bash
mkdir -p manual
cp source/sparql.csv manual/
perl -pi -e 's/\r\n/\n/' manual/sparql.csv
perl -pi -e 's/\r/\n/g' manual/sparql.csv
cat manual/sparql.csv | grep http | awk -F, '{print $1}' | sed 's/"//g' | awk '{print "uriSpaces.add(\""$0"\");"}' > manual/sparql.csv.java
