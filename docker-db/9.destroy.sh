#!/bin/bash
cd `dirname $0`
dbdock=`cat ../.config-db/db.dock`
sudo docker kill $dbdock
sudo docker rm $dbdock

