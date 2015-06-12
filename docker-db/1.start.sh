#!/bin/bash
cd `dirname $0`
dbdock=`cat ../.config-db/db.dock`
sudo docker start $dbdock 
