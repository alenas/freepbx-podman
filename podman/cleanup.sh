#!/bin/bash

if [ $# -eq 1 ]  
then
    podman pod stop $1;
    podman pod rm $1;
    podman volume rm $1-db;
    rm -f -r /$1/data/*;
    rm -f -r /$1/logs/*;
    rm -f -r /$1/www/*;
else
    echo "Bad prompt: " $@;
fi


