#!/bin/bash
cd `dirname $0`
serverdock=`cat ../.config-server/server.dock`
sudo docker stop $serverdock

