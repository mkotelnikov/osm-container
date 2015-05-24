#!/bin/bash
dbdock=`cat ../.db-config/db.dock`
sudo docker stop $dbdock

