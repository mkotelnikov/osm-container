#!/bin/bash

cd `dirname $0`
scriptsDir=`pwd`
dbdock=`cat ../.db-config/db.dock`
dbhost=`cat ../.db-config/db.host`
dbport=`cat ../.db-config/db.port`
dbuser=`cat ../.db-config/db.user`
dbpass=`cat ../.db-config/db.pass`
dbname=`cat ../.db-config/db.name`
dbencode="UTF8"

echo "$dbhost:$dbport:*:$dbuser:$dbpass" >$HOME/.pgpass
chmod 0600 $HOME/.pgpass

echo `cat $HOME/.pgpass`

dropdb -h "$dbhost" -p "$dbport" -U "$dbuser" "$dbname"

createdb -h "$dbhost" -p "$dbport" -U "$dbuser" "$dbname" -E "$dbencode"

createlang -h "$dbhost" -p "$dbport"  -U "$dbuser" plpgsql "$dbname"

psql -h "$dbhost" -p "$dbport" -U "$dbuser" -d "$dbname" \
    -c 'create extension postgis; create extension hstore;'

# psql -h "$dbhost" -p "$dbport" -U "$dbuser" -d "$dbname" \
#    -c 'create schema if not exists import'
# psql -h "$dbhost" -p "$dbport" -U "$dbuser" -d "$dbname" \
#    -c 'create schema if not exists osm'

psql -h "$dbhost" -p "$dbport" -U "$dbuser" -d "$dbname" -f "$scriptsDir/0.db-rebuild.sql"
