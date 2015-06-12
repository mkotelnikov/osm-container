#!/bin/bash

cd `dirname $0`
dbhost=`cat ../.config-db/db.host`
dbport=`cat ../.config-db/db.port`
dbuser=`cat ../.config-db/db.user`
dbpass=`cat ../.config-db/db.pass`

psql -h "${dbhost}" -p $dbport -U $dbuser -W -d postgres
