#!/bin/bash

cd `dirname $0`
dbdock=`cat ../.config-db/db.dock`
dbhost=`cat ../.config-db/db.host`
dbport=`cat ../.config-db/db.port`
dbuser=`cat ../.config-db/db.user`
dbpass=`cat ../.config-db/db.pass`
dbname=`cat ../.config-db/db.name`

sudo docker run -it --link $dbdock:postgres --rm postgres sh -c "exec psql postgres://$dbuser:$dbpass@\$POSTGRES_PORT_5432_TCP_ADDR:\$POSTGRES_PORT_5432_TCP_PORT/$dbname" 
 
