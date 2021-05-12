#!/bin/bash

podname=pbx
version=184

### check if environment is set
if [ ! -f .env ]; then
    echo 'You need to create .env file from default.env first!'
    exit 1
fi

echo "Stopping and disabling $podname services"
systemctl stop pod-pbx
systemctl disable pod-pbx
systemctl disable container-pbx-app
systemctl disable container-pbx-db

echo 'Stopping and removing APP container: ' $podname-app
podman pod stop $podname
podman rm $podname-app

### stop db and backup everything
echo 'Backing up...'
#rsync -a /pbx/ ~/backup/pbx-dir.bkp.$(date +%Y%m%d-%H.%M.%S)

echo 'Creating APP container: ' $podname-app
### create app container - run attached to 
podman create --name $podname-app --pod $podname \
    --runtime=/usr/lib/cri-o-runc/sbin/runc \
    -v /$podname/data:/data \
    -v /$podname/logs:/var/log \
    -v /$podname/www:/var/www/html \
    --env-file=.env \
    --cap-add=NET_ADMIN \
        al3nas/freepbx:$version

echo "Creating new PBX services"
podman generate systemd -f -n -t=30 $podname
mv -f *.service /etc/systemd/system/

echo "Enabling services"
systemctl enable pod-$podname
systemctl enable container-$podname-app
systemctl enable container-$podname-db

#systemctl start pod-$podname
### remind to refresh signatures 
echo "Run this after it starts: podman exec -t $podname-app fwconsole util signaturecheck"
