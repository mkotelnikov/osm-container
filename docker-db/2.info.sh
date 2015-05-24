#!/bin/bash

cd `dirname $0`
dbdock=`cat ../.db-config/db.dock`
dbhost=`cat ../.db-config/db.host`
dbport=`cat ../.db-config/db.port`
dbuser=`cat ../.db-config/db.user`
dbpass=`cat ../.db-config/db.pass`
dbname=`cat ../.db-config/db.name`

echo "* dbdock=$dbdock"
echo "* dbhost=$dbhost"
echo "* dbport=$dbport"
echo "* dbuser=$dbuser"
echo "* dbpass=$dbpass"
echo "* dbname=$dbname"

