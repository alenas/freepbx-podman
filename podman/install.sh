#!/bin/bash
podname=pbx
version=latest

### check if environment is set
if [ ! -f .env ]; then
    echo 'You need to create .env file from default.env first!'
    exit 1
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
    --runtime=/usr/lib/cri-o-runc/sbin/runc \
    --network static \
    -p 80:80/tcp -p 443:443/tcp \
    -p 7520-7521:5060-5061/tcp -p 7520-7521:5060-5061/udp \
    -p 8089:8089 \
    -p 18000-18200:18000-18200/udp

echo 'Starting pod: ' $podname
podman pod start $podname

echo 'Running DB container: ' $podname-db
### create db container
podman run -d --name $podname-db --pod $podname \
    --runtime=/usr/lib/cri-o-runc/sbin/runc \
    -v /$podname/db:/var/lib/mysql \
    --env-file=.env \
        mariadb:10.5

echo 'Running APP container: ' $podname-app
### create app container 
podman run -d --name $podname-app --pod $podname \
    --runtime=/usr/lib/cri-o-runc/sbin/runc \
    -v /$podname/data:/data \
    -v /$podname/logs:/var/log \
    -v /$podname/www:/var/www/html \
    --env-file=.env \
    --cap-add=NET_ADMIN \
        al3nas/freepbx:$version