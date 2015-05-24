#!/bin/bash

cd `dirname $0`
dbhost=`cat ../.db-config/db.host`
dbport=`cat ../.db-config/db.port`
dbuser=`cat ../.db-config/db.user`
dbpass=`cat ../.db-config/db.pass`

psql -h "${dbhost}" -p $dbport -U $dbuser -W -d postgres
