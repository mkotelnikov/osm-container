#!/bin/bash
cd `dirname $0`
dbdock=`cat ../.db-config/db.dock`
sudo docker start $dbdock 
