#!/bin/bash

#------------------------------------------
# Variables initialization 
cd `dirname $0`
cd ..
dir=`pwd`
serverdock=osm-nodejs
serverhost=127.0.0.1
serverport=4321
server_internal_port=9876

if [ ! -d .config-server ]; then
    mkdir .config-server
    echo "$serverdock" > .config-server/server.dock
    echo "$serverhost" > .config-server/server.host
    echo "$serverport" > .config-server/server.port
    sudo docker build -t nodejs -f ./docker-server/Dockerfile .
fi

dbdock=`cat .config-db/db.dock`
dockerimage=$serverdock

sudo docker build -t $dockerimage "$dir/docker-server"

sudo docker run -t --name $serverdock \
    -p $serverhost:$serverport:$server_internal_port \
    --link $dbdock:db \
    -v "$dir/server:/app/server:rw"\
    -d $dockerimage

sudo docker exec $serverdock /nodejs/bin/npm install

sudo docker stop $serverdock