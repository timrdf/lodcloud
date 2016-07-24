#!/bin/bash

# http://lod-cloud.net/#history
for version in `echo 2014-08-30 \\
                     2011-09-19 \\
                     2010-09-22 \\
                     2009-07-14 \\
                     2009-03-27 \\
                     2009-03-05 \\
                     2008-09-18 \\
                     2008-03-31 \\
                     2008-02-28 \\
                     2007-11-10 \\
                     2007-11-07 \\
                     2007-10-08 \\
                     2007-05-01`; do
   #if [[ ! -e $version ]]; then
      mkdir -p $version && pushd $version
         for color in "" "_colored"; do
            for format in png pdf svg; do
               cr-dcat-retrieval-url.sh -w "http://lod-cloud.net/versions/$version/lod-cloud$color.$format"
            done
         done
      popd
   #fi
done
