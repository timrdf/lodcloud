#!/bin/bash

echo "`find source/ -name "*.txt" | wc -l` tagged lod"
echo "`find source/ -name "*.txt" | grep "is-contactable\/" | wc -l` originally contactable"
echo "    `find source/ -name "*.txt" | grep "is-contactable\/" | grep not-in-lodcloud | wc -l` not in lodcloud"
echo "    `find source/ -name "*.txt" | grep "is-contactable\/" | grep is-in-lodcloud | wc -l` in lodcloud"
echo " `find source/ -name "*.txt" | grep "is-contactable-by-recovery" | wc -l` contactable by recovery"
echo "     `find source/ -name "*.txt" | grep "is-contactable-by-recovery" | grep not-in-lodcloud | wc -l` not in lodcloud"
echo "     `find source/ -name "*.txt" | grep "is-contactable-by-recovery" | grep is-in-lodcloud | wc -l` in lodcloud"
echo " `find source/ -name "*.txt" | grep "not-contactable" | wc -l` not contactable"
echo "     `find source/ -name "*.txt" | grep "not-contactable" | grep not-in-lodcloud | wc -l` not in lodcloud"
echo "     `find source/ -name "*.txt" | grep "not-contactable" | grep is-in-lodcloud | wc -l` in lodcloud"
