#!/bin/bash

if [[ "$1" != 'rename-compress' ]]; then

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

else 
   # Downloaded 692G for 11,904 files.
   pushd source 2>&1 /dev/null
      for url in `find . -name "*.url"`; do
         file=${url%.url}
         if [[ -e "$file" ]]; then
            du -sh $file | awk '{print $2,$1}'
            if [[ `gzipped.sh "$file"` == 'yes' ]]; then
               file $file
            elif [[ -h "$file" ]]; then
               # It has already been processed.
               echo "$file -> `readlink $file` (already)"
            else
               new=`rename-by-syntax.sh -v --mark-invalid --good-guess-is-valid-enough "$file"`
               if [[ -e "$new" && "$new" != "$file" && "$new" != *invalid* ]]; then
                  echo "$file -> $new.gz"
                  touch $url
                  cat "$new" | gzip > $new.gz && rm "$new"
                  ln -s  "$new.gz" "$file"
                  du -sh "$new.gz" | awk '{print $2,$1}'
               else
                  echo "$file -> $new ??"
                  if [[ "$new" != "$file" ]]; then
                     touch $url
                     ln -s "$new"    "$file"
                  fi
               fi
            fi
         fi 
      done
   popd
fi
