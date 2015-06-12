#!/bin/bash

cd `dirname $0`
dbdock=`cat ../.config-db/db.dock`
dbhost=`cat ../.config-db/db.host`
dbport=`cat ../.config-db/db.port`
dbuser=`cat ../.config-db/db.user`
dbpass=`cat ../.config-db/db.pass`
dbname=`cat ../.config-db/db.name`

echo "* dbdock=$dbdock"
echo "* dbhost=$dbhost"
echo "* dbport=$dbport"
echo "* dbuser=$dbuser"
echo "* dbpass=$dbpass"
echo "* dbname=$dbname"

