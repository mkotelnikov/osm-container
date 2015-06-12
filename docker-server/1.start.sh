#!/bin/bash
cd `dirname $0`
serverdock=`cat ../.config-server/server.dock`
serverhost=`cat ../.config-server/server.host`
serverport=`cat ../.config-server/server.port`
sudo docker start $serverdock

