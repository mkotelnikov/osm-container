#!/bin/bash

echo ""
if [ "$1" = "clean" ]; then
    list=$(sudo docker ps -aq)
    if [ "$list" != "" ]; then
        echo "Try to remove the following containers:"
        echo "$list" 
        sudo docker rm $list
        echo "Done."
    else
        echo "Nothing to remove"
    fi
else
    echo "This command removes all old not running Docker containers."
    echo "Usage: "
    echo "> ./reset-all.sh clean"
    ## http://stackoverflow.com/questions/17236796/how-to-remove-old-docker-containers
fi
echo ""
  

