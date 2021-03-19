#!/bin/bash
if [ $# -ne 2 ]  
then 
    echo 'Need 2 parameters: PODNAME, VERSION. Got: ' $@
    exit 1
fi

podname=$1
version=$2

### check if environment is set
if [ ! -f .env ]; then
    echo 'You need to create .env file from default.env first!'
    exit 1
fi

echo 'Stopping and removing APP container: ' $podname-app
podman stop $podname-app
podman rm $podname-app

### stop db and backup everything
podman stop $podname-db
echo 'Backing up...'
rsync -a /pbx/ ~/backup/pbx-dir.bkp.$(date +%Y%m%d-%H.%M.%S)
podman start $podname-db


echo 'Running APP container: ' $podname-app
### create app container - run attached to 
podman run -d --name $podname-app --pod $podname \
    --runtime=/usr/lib/cri-o-runc/sbin/runc \
    -v /$podname/data:/data \
    -v /$podname/logs:/var/log \
    -v /$podname/www:/var/www/html \
    --env-file=.env \
    --cap-add=NET_ADMIN \
        al3nas/freepbx:$version

### remind to refresh signatures 
echo "Run this after it starts: podman exec -t $podname-app fwconsole ma refreshsignatures"
#podman attach $podname-app