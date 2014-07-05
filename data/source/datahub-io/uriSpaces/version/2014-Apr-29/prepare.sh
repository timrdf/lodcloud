#!/bin/bash

mkdir -p automatic

cat source/sparql.csv | grep http | awk -F, '{print $1}' | sed 's/"//g' > automatic/sparql.csv
perl -pi -e 's/\r\n/\n/' automatic/sparql.csv
perl -pi -e 's/\r/\n/g'  automatic/sparql.csv

cat automatic/sparql.csv | awk '{print "uriSpaces.add(\""$0"\");"}' > automatic/sparql.csv.java

export BTE_PACKAGE
#                                                                OLD          
cat automatic/sparql.csv | java $BTE_PACKAGE.StringTreeEntry - +   > automatic/sparql.impl.str
cat automatic/sparql.csv | java $BTE_PACKAGE.StringTreeEntry - + + > automatic/sparql.one.str
#                                                                NEW
diff -y -W 138 automatic/sparql.one.str automatic/sparql.impl.str
