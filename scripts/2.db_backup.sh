#!/bin/bash

command=$1
current_dir=`pwd`
dumpfile="$current_dir/$2"

usage(){
   echo "Usage:"
   echo "> 2.db_backup.sh dump|restore <dump_file>"
}

if [ "$command" = "" ]; then
    usage
    exit 1;
fi

if [ "$2" = "" ]; then
    usage
    exit 1;
fi

cd `dirname $0`

scriptsDir=`pwd`
dbdock=`cat ../.config-db/db.dock`
dbhost=`cat ../.config-db/db.host`
dbport=`cat ../.config-db/db.port`
dbuser=`cat ../.config-db/db.user`
dbpass=`cat ../.config-db/db.pass`
dbname=`cat ../.config-db/db.name`
dbencode="UTF8"

dump() {
   echo "Create backup '$dumpfile'..."
   pg_dump -h "$dbhost" -p "$dbport" -U "$dbuser" -d "$dbname" > "$dumpfile"
   echo "Done."
}

restore() {
   echo "Restoring backup from '$dumpfile'..."
   psql -h "$dbhost" -p "$dbport" -U "$dbuser" -d "$dbname" < "$dumpfile"
   echo "Done."
}

$command

