#!/bin/bash
#

python ../../src/contacts.py ../../src/lod.ttl text/turtle | tee source/lod.ttl

# Short circuit the publishing to a temporary file:

#tar czf contacts.tgz source
#sudo mv contacts.tgz /var/www/contacts.tgz
