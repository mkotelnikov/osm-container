#!/bin/bash

cd `dirname $0`
dbdock=`cat ../.config-db/db.dock`
dbhost=`cat ../.config-db/db.host`
dbport=`cat ../.config-db/db.port`
dbuser=`cat ../.config-db/db.user`
dbpass=`cat ../.config-db/db.pass`
dbname=`cat ../.config-db/db.name`

echo "Preparing the postgis:2.1 image (github.com/helmi03/docker-postgis.git)..."
sudo docker build -t postgis:2.1 github.com/helmi03/docker-postgis.git
echo "Done."

# sudo docker run --name $dbdock -d -v $HOME/postgres_data:/var/lib/postgresql postgis:2.1
# sudo docker run --name $dbdock -p $dbhost:$dbport:5432 -d postgis:2.1
sudo docker run --name $dbdock -p $dbhost:$dbport:5432 -d postgis:2.1
