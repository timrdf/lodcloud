#!/bin/bash

mkdir source

service='http://aquarius.tw.rpi.edu/projects/datafaqs/services/sadi/core/select-datasets/by-ckan-group'
curl -H "Content-type: text/turtle" -d ' <http://datahub.io/group/lodcloud> a <http://purl.org/twc/vocab/datafaqs#CKANGroup> .' $service > source/lodcloud-group.ttl
