#!/bin/bash
dbdock=`cat ../.db-config/db.dock`
sudo docker start $dbdock 
