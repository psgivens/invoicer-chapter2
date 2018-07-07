#!/bin/sh

    sudo docker network list | grep -E 'secdevops|NAME'
    echo ""
    sudo docker volume list | grep -E 'secdevops|NAME'
    echo ""
    sudo docker container list -a | grep -E "NAMES|secdevops"
    echo ""
    echo "PGSQLID = $PGSQLID"
