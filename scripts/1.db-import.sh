#!/bin/bash

osm_file=$1
if [ "$osm_file" = "" ]; then
    echo "Usage:"
    echo " 1.db-import.sh ../data/osm.pbf"
    exit 1; 
fi

cd `dirname $0`
scriptsDir=`pwd`
dbdock=`cat ../.db-config/db.dock`
dbhost=`cat ../.db-config/db.host`
dbport=`cat ../.db-config/db.port`
dbuser=`cat ../.db-config/db.user`
dbpass=`cat ../.db-config/db.pass`
dbname=`cat ../.db-config/db.name`
dbencode="UTF8"

run() {
   import_osm --create
   psql -h "$dbhost" -p "$dbport" -U "$dbuser" -d "$dbname" -f "$scriptsDir/1.db-import.sql"
}

import_osm() {
    rebuild=$1
    osm2pgsql \
     $rebuild\
     --slim\
     --hstore-all\
     --extra-attributes\
     --host $dbhost --port $dbport --username $dbuser --database $dbname "$osm_file"
}

run

