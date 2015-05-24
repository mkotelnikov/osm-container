#!/bin/bash
dbdock=`cat ../.db-config/db.dock`
sudo docker kill $dbdock
sudo docker rm $dbdock

