#!/bin/bash
#
#3> <> rdfs:seeAlso <https://github.com/jimmccusker/twc-healthdata/wiki/Automation>;
#3>    prov:specializationOf <https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/cr-cron.sh> .
#3>    prov:wasDerivedFrom   <https://raw.github.com/jimmccusker/twc-healthdata/master/data/source/healthdata-tw-rpi-edu/cr-cron/version/cron.sh> .

if [ "$1" == "--help" ]; then
   # Determine the absolute path to this script.
   D=`dirname "$0"`
   script_home="`cd \"$D\" 2>/dev/null && pwd || echo \"$D\"`"

   echo
   echo "This script is run by cron to automate an installation of csv2rdf4lod-automation."
   echo "  See:"
   echo "    https://github.com/jimmccusker/twc-healthdata/wiki/Automation"
   echo "    https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/cr-cron.sh"
   echo
   echo "Place something similar to the following into your crontab (by running 'crontab -e')"
   echo
   echo "# m h  dom mon dow   command"
   echo "`date +%M` `date +%k`  *   *   *     $script_home/`basename $0`"
   echo
   echo "# ^^ Be sure to put an extra newline, or the last command will not invoke."
   exit
fi

pushd `dirname $0` &> /dev/null

   # Boostrap ourselves with environment variables and paths.
   source ../../../csv2rdf4lod-source-me-as-`whoami`.sh

   see='https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-not-set'
   if [[ "${#CSV2RDF4LOD_HOME}" -eq 0 ]]; then
      echo "[ERROR] CSV2RDF4LOD_HOME is not set; cannot continue." > `dirname $0`/bootstrap-error.txt
      echo "        see $see"                                     >> `dirname $0`/bootstrap-error.txt
      date                                                        >> `dirname $0`/bootstrap-error.txt
   fi

   versionID=`md5.sh $0` # < - - - needs - /\
   mkdir -p $versionID/doc/logs
   logID=`date +%Y-%b-%d_%H_%M`

   lock=`pwd`/.lock
   log=`pwd`/$versionID/doc/logs/cron-$logID.log # - - - - - - - - - log - - - - - - - - - - - -
   conversion_root=`cr-conversion-root.sh`
popd &> /dev/null

pushd $conversion_root &> /dev/null

   #
   # Starting user and time.
   echo "BEGIN cron ps --user `whoami` `date`"                                              >> $log
   echo "#3> <#cron> a prov:Activity; prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   ps --user `whoami`                                                                       >> $log
   echo "END cron ps --user `whoami` `date`"                                                >> $log
   echo                                                                                     >> $log

   #
   # PID
   echo "BEGIN cron pid"                                                                         >> $log
   echo "#3> <#cron> <http://semanticscience.org/resource/software-process-identifier> \"$$\" ." >> $log
   echo $$                                                                                       >> $log
   echo "END cron pid"                                                                           >> $log
   echo                                                                                          >> $log

   # Replaced with .lock:
   #already_running=`ps --user \`whoami\` | grep 'cron.sh' | grep -v 'grep' | wc -l | awk '{printf("%s",$1)}'`
   #echo "Number of cron.sh already_running:$already_running:" >> $log
   #if [[ ${#already_running} -gt 0 && "$already_running" -gt 1 ]]; then
   #   echo                                                    >> $log
   #   echo "cron.sh is already running; aborting."            >> $log
   #   ps --user `whoami` | grep 'cron.sh'                     >> $log
   #   ps --user `whoami` | grep 'cron.sh' | wc -l             >> $log
   #   exit 1
   #fi
   if [ -e $lock ]; then
      echo "cron.sh lock exists; aborting ($lock)."           >> $log
      echo "END cron `date`"                                  >> $log
      exit 1
   else
      echo $$ `date` > $lock
   fi
   echo                                                       >> $log


   wasInformed='a prov:Activity; prov:wasInformedBy <#cron>;'
   #
   # Git any new dcat.ttl, retrieve.sh, and update this cron script.
   echo "BEGIN cron git pull `date`"    >> $log
   echo "#3> <#git-pull> $wasInformed prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   if [ `which git` ]; then
      git pull 2>&1                     >> $log
   else
      echo "ERROR: git is not on PATH." >> $log
   fi
   echo "END cron git pull `date`"      >> $log
   echo                                 >> $log
  
 
   #
   # CSV2RDF4LOD_* environment variables control the processing.
   echo "BEGIN cron cr-vars.sh `date`"      >> $log
   echo "user name: $SUDO_USER as `whoami`" >> $log
   cr-vars.sh                               >> $log
   echo "END cron cr-vars.sh `date`"        >> $log
   echo                                     >> $log


   #
   # Populate our local writable CKAN instance with the entries from a third party CKAN instance.
   echo "BEGIN cron cr-mirror-ckan.py `date`"                                            >> $log
   echo "#3> <#cr-mirror-ckan> $wasInformed prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   if [[ "$CSV2RDF4LOD_CKAN" == "true"  && \
        -n "$CSV2RDF4LOD_CKAN_SOURCE"   && \
        -n "$CSV2RDF4LOD_CKAN_WRITABLE" && \
        -n "$X_CKAN_API_Key"            && \
        `which cr-mirror-ckan.py` ]]; then
      echo cr-mirror-ckan.py $CSV2RDF4LOD_CKAN_SOURCE/api $CSV2RDF4LOD_CKAN_WRITABLE/api >> $log
      cr-mirror-ckan.py $CSV2RDF4LOD_CKAN_SOURCE/api $CSV2RDF4LOD_CKAN_WRITABLE/api 2>&1 >> $log
   else
      echo "   ERROR: Failed to invoke cr-mirror-ckan.py:"                               >> $log
      echo "      CSV2RDF4LOD_CKAN:          $CSV2RDF4LOD_CKAN"                          >> $log
      echo "      CSV2RDF4LOD_CKAN_SOURCE:   $CSV2RDF4LOD_CKAN_SOURCE"                   >> $log
      echo "      CSV2RDF4LOD_CKAN_WRITABLE: $CSV2RDF4LOD_CKAN_WRITABLE"                 >> $log
      echo "      cr-mirror-ckan.py path:    `which cr-mirror-ckan.py`"                  >> $log
      echo "      X_CKAN_API_Key:            $X_CKAN_API_Key"                            >> $log
   fi
   echo "END cron cr-mirror-ckan.py `date`"                                              >> $log
   echo                                                                                  >> $log


   #
   # cr-retrieve.sh follows the DCAT descriptions to download the files.
   echo "BEGIN cron cr-retrieve.sh `date`"           >> $log
   echo "#3> <#cr-retrieve> $wasInformed prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   example="hub-healthdata-gov/food-recalls"
   example=""
   if [ -n "$example" ]; then
      pushd $example
      echo "(only working with example `cr-pwd.sh`)" >> $log
   fi
   cr-retrieve.sh -w --skip-if-exists 2>&1           >> $log
   if [ -n "$example" ]; then
      popd
   fi
   echo "END cron cr-retrieve.sh `date`"             >> $log
   echo                                              >> $log


   # TODO: fix https://github.com/timrdf/csv2rdf4lod-automation/issues/313 and reinstate this.
   #
   # Turtle In Comments often has PROV-O assertions about the files in which they are embedded.
   #echo "BEGIN cron cr-publish-tic-to-endpoint.sh `date`"                                         >> $log
   #echo "#3> <#cr-publish-tic> $wasInformed prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   #if [[ ${#CSV2RDF4LOD_BASE_URI}              -gt 0 && \
   #      ${#CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID} -gt 0 && \
   #      `which cr-publish-tic-to-endpoint.sh` ]]; then
   #   echo "pwd:    `pwd`"                                                                        >> $log
   #   echo "script: `which cr-publish-tic-to-endpoint.sh`"                                        >> $log
   #   echo cr-publish-tic-to-endpoint.sh cr:auto                                                  >> $log
   #   cr-publish-tic-to-endpoint.sh cr:auto                                                  2>&1 >> $log
   #else
   #   echo "   ERROR: Failed to invoke cr-publish-tic-to-endpoint.sh:"                            >> $log
   #   echo "      CSV2RDF4LOD_BASE_URI:              $CSV2RDF4LOD_BASE_URI"                       >> $log
   #   echo "      CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID: $CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID"          >> $log
   #   echo "                                    path: `which cr-publish-tic-to-endpoint.sh`"      >> $log
   #fi
   #echo "END cron cr-publish-tic-to-endpoint.sh `date`"                                           >> $log
   #echo                                                                                           >> $log


   #
   # cr-publish.sh 
   # https://github.com/timrdf/csv2rdf4lod-automation/wiki/Triggers#4-publication-triggers
   echo "BEGIN cron cr-publish.sh `date`"                                                     >> $log
   echo "#3> <#cr-publish> $wasInformed prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   cr-publish.sh --idempotent 2>&1                                                            >> $log
   echo "END cron cr-publish.sh `date`"                                                       >> $log
   echo                                                                                       >> $log


   #
   # Gather all versioned dataset dump files into a "one click" download.
   echo "BEGIN cron cr-full-dump.sh `date`"                                                     >> $log
   echo "#3> <#cr-full-dump> $wasInformed prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   if [[ -n "$CSV2RDF4LOD_BASE_URI"              && \
         -n "$CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID" && \
         `which cr-full-dump.sh` ]]; then
      echo "pwd: `pwd`"                                                                         >> $log
      cr-full-dump.sh                                                               2>&1        >> $log
   else
      echo "   ERROR: Failed to invoke:"                                                        >> $log
      echo "      CSV2RDF4LOD_BASE_URI:              $CSV2RDF4LOD_BASE_URI"                     >> $log
      echo "      CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID: $CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID"        >> $log
      echo "                                   path: `which cr-full-dump.sh`"                   >> $log
   fi
   echo "END cron cr-full-dump.sh `date`"                                                       >> $log
   echo                                                                                         >> $log


   #
   # Search the RDF Node URIs in our dataset that come from other Linked Data cloud bubbbles' namespaces.
   # This needs to be run AFTER cr-full-dump.sh
   echo "BEGIN cron cr-linksets.sh `date`"                                                                                 >> $log
   echo "#3> <#cr-linksets> $wasInformed prov:startedAtTime `dateInXSDDateTime.sh --turtle` ."                             >> $log
   if [[ -n "$CSV2RDF4LOD_BASE_URI"                               && \
         -n "$CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID"                  && \
         -n "$CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID" && \
         `which cr-linksets.sh` ]]; then
      echo "pwd: `pwd`"                                                                                                    >> $log
      cr-linksets.sh                                                                                                       >> $log
   else
      echo "   ERROR: Failed to invoke:"                                                                                   >> $log
      echo "      CSV2RDF4LOD_BASE_URI:              $CSV2RDF4LOD_BASE_URI"                                                >> $log
      echo "      CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID: $CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID"                                   >> $log
      echo "      CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID: $CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID" >> $log
      echo "                                   path: `which cr-linksets.sh`"                                               >> $log
   fi
   echo "END cron cr-linksets.sh `date`"                                                                                   >> $log
   echo                                                                                                                    >> $log


   #
   # Submit this site's latest lodcloud-specific metadata to datahub.io.
   echo "BEGIN cron cr-pingback.sh `date`"                                                     >> $log
   echo "#3> <#cr-pingback> $wasInformed prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   if [[ -n "$CSV2RDF4LOD_BASE_URI"                               && \
         -n "$CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID"                  && \
         -n "$CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID" && \
         `which cr-pingback.sh` ]]; then
      echo "pwd: `pwd`"                                                                       >> $log
      cr-pingback.sh                                                                          >> $log
   else
      echo "   ERROR: Failed to invoke:"                                                      >> $log
      echo "      CSV2RDF4LOD_BASE_URI:                               $CSV2RDF4LOD_BASE_URI"                 >> $log
      echo "      CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID:                  $CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID"    >> $log
      echo "      CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID: $CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID" >> $log
      echo "                                   path: `which cr-pingback.sh`"                  >> $log
   fi
   echo "END cron cr-pingback.sh `date`"                                                      >> $log
   echo                                                                                       >> $log


popd &> /dev/null

echo                                                                                   >> $log
echo "#3> <#cron> a prov:Activity; prov:endedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
echo "END cron `date`"                                                                 >> $log
rm $lock
