#!/bin/bash

command=$1
dumpfile=$2

usage(){
   echo "Usage:"
   echo "> 2.db_backup.sh dump|restore <dump_file>"
}

if [ "$command" = "" ]; then
    usage
    exit 1;
fi

if [ "$dumpfile" = "" ]; then
    usage
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

dump() {
   echo "Create backup '$dumpfile'..."
   pg_dump -h "$dbhost" -p "$dbport" -U "$dbuser" -d "$dbname" > "$dumpfile"
   echo "Done."
}

restore() {
   echo "Restoring backup from '$dumpfile'..."
   psql -h "$dbhost" -p "$dbport" -U "$dbuser" -d "$dbname" < "$psql"
   echo "Done."
}

$command

