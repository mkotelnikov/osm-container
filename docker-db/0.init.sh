#!/bin/bash

cd `dirname $0`
cd ..
dir=`pwd`
dbdock=`cat .config-db/db.dock`
dbhost=`cat .config-db/db.host`
dbport=`cat .config-db/db.port`
dbuser=`cat .config-db/db.user`
dbpass=`cat .config-db/db.pass`
dbname=`cat .config-db/db.name`

echo "Preparing the postgres image..."
sudo docker build -t postgis-plv8 $dir/docker-db

sudo docker run \
    -v $dir/.config-db:/db/.config-db:rw \
    -v $dir/data:/db/data:rw \
    -v $dir/docker-db/0.init:/docker-entrypoint-initdb.d \
    -e POSTGRES_USER=$dbuser \
    -e POSTGRES_PASSWORD=$dbpass \
    -e POSTGRES_DB=$dbname \
    -e PGDATA=/db/data/pgdata \
    --name $dbdock \
    -p $dbhost:$dbport:5432 \
    -d postgis-plv8
    
echo "Done."
