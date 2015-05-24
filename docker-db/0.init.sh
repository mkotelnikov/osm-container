#!/bin/bash

dbdock=osm-postgis
dbname=osm
dbhost=127.0.0.1
dbport=65432
dbuser=docker
dbpass=docker

cd `dirname $0`
mkdir ../.db-config
echo "$dbdock" > ../.db-config/db.dock
echo "$dbhost" > ../.db-config/db.host
echo "$dbport" > ../.db-config/db.port
echo "$dbuser" > ../.db-config/db.user
echo "$dbpass" > ../.db-config/db.pass
echo "$dbname" > ../.db-config/db.name

sudo docker build -t postgis:2.1 github.com/helmi03/docker-postgis.git
# sudo docker run --name $dbdock -d -v $HOME/postgres_data:/var/lib/postgresql postgis:2.1
# sudo docker run --name $dbdock -p $dbhost:$dbport:5432 -d postgis:2.1
sudo docker run --name $dbdock -p $dbhost:$dbport:5432 -d postgis:2.1
