#!/bin/bash

if [ "$1" = "" ]; then
    echo "Usage:"
    echo " 1.db-import.sh ../data/osm.pbf"
    exit 1; 
fi

osm_file_dir=`pwd`
osm_file="$osm_file_dir/$1"

cd `dirname $0`
scriptsDir=`pwd`
dbdock=`cat ../.config-db/db.dock`
dbhost=`cat ../.config-db/db.host`
dbport=`cat ../.config-db/db.port`
dbuser=`cat ../.config-db/db.user`
dbpass=`cat ../.config-db/db.pass`
dbname=`cat ../.config-db/db.name`
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

