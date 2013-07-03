#!/bin/bash

if [[ `cr-pwd-type.sh` == "cr:conversion-cockpit" ]]; then
   curl -O http://datafaqstest.tw.rpi.edu/contacts.tgz
   tar zxf contacts.tgz
   rm contacts.tgz
   mkdir -p manual/todo
   for txt in `find source/ -name "*.txt" | grep -v "not-contactable"`; do ln $txt manual/todo/; done
   mkdir manual/tailored-aggregate
   mkdir manual/lod.tdb
   tdbloader --loc=manual/lod.tdb source/lod.ttl
   tdbquery  --loc=manual/lod.tdb --query=../../src/aggregate.rq

   mkdir manual/tailored-aggregate/bioportal
   for email in `grep -l 'support@bioontology.org' manual/todo/*`; do mv $email manual/tailored-aggregate/bioportal/; done
   mkdir manual/tailored-aggregate/hugh
   for email in `grep -l 'hg@ecs.soton.ac.uk' manual/todo/*`; do mv $email manual/tailored-aggregate/hugh/; done
   mkdir manual/tailored-aggregate/bio2rdf
   for email in `grep -l 'bio2rdf@googlegroups.com' manual/todo/*`; do mv $email manual/tailored-aggregate/bio2rdf/; done
   mkdir manual/tailored-aggregate/gnoss
   for email in `grep -l 'gnoss@gnoss.com' manual/todo/*`; do mv $email manual/tailored-aggregate/gnoss/; done
   mkdir manual/tailored-aggregate/eagle-i
   for email in `grep -l 'info@eagle-i.org' manual/todo/*`; do mv $email manual/tailored-aggregate/eagle-i/; done
   mkdir manual/tailored-aggregate/hendler
   for email in `grep -l 'hendler@cs.rpi.edu' manual/todo/*`; do mv $email manual/tailored-aggregate/hendler/; done
else
   echo need to be in cr:conversion-cockpit
fi
