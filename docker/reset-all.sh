#!/bin/bash

## Danger! Please de-comment the code below to remove all old Docker containers 
## http://stackoverflow.com/questions/17236796/how-to-remove-old-docker-containers  
docker rm $(docker ps -aq)

## sudo docker rm `sudo docker ps --no-trunc -aq`

