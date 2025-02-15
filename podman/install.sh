#!/bin/bash
podname=pbx
version=18.5

### check if environment is set
if [ ! -f .env ]; then
    echo 'You need to create .env file from default.env first!'
    return 1
fi

mkdir -p /$podname/data
mkdir -p /$podname/www
mkdir -p /$podname/logs
mkdir -p /$podname/db

echo 'Cleaning up previous pods...'
podman pod stop $podname
podman pod rm $podname

echo 'Creating pod: ' $podname
### create pod
podman pod create -n $podname --hostname voip.pir.lt \
    --ip=10.88.0.4 \
    -p 80:80/tcp -p 443:443/tcp \
    -p 5060:5060/udp -p 5060:5060/tcp \
    -p 7520-7521:5060-5061/tcp -p 7520-7521:5060-5061/udp \
    -p 8089:8089 \
    -p 18000-18200:18000-18200/udp

echo 'Starting pod: ' $podname
podman pod start $podname

echo 'Running DB container: ' $podname-db
### create db container
podman run -d --name $podname-db --pod $podname \
    -v /$podname/db:/var/lib/mysql \
    --env-file=.env \
        mariadb:10.5

echo 'Running APP container: ' $podname-app
### create app container 
podman run -d --name $podname-app --pod $podname \
    -v /$podname/data:/data \
    -v /$podname/logs:/var/log \
    -v /$podname/www:/var/www/html \
    --env-file=.env \
    --cap-add=NET_ADMIN \
        al3nas/freepbx:$version
