#!/bin/bash

dbdock=osm-postgis
dbname=osm
dbhost=127.0.0.1
dbport=65432
dbuser=docker
dbpass=docker

cd `dirname $0`
mkdir ../.config-db
echo "$dbdock" > ../.config-db/db.dock
echo "$dbhost" > ../.config-db/db.host
echo "$dbport" > ../.config-db/db.port
echo "$dbuser" > ../.config-db/db.user
echo "$dbpass" > ../.config-db/db.pass
echo "$dbname" > ../.config-db/db.name

sudo docker build -t postgis:2.1 github.com/helmi03/docker-postgis.git
# sudo docker run --name $dbdock -d -v $HOME/postgres_data:/var/lib/postgresql postgis:2.1
# sudo docker run --name $dbdock -p $dbhost:$dbport:5432 -d postgis:2.1
sudo docker run --name $dbdock -p $dbhost:$dbport:5432 -d postgis:2.1
