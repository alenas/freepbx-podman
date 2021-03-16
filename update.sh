#!/bin/bash
if [ $# -ne 2 ]  
then 
    echo 'Need 2 parameters: PODNAME, VERSION. Got: ' $@
    exit 1
fi

podname=$1
version=$2

### reuse DB credentials
. set-env-pwd.sh

echo 'Stopping and removing APP container: ' $podname-app
podman stop $podname-app
podman rm $podname-app

echo 'Backing up...'
#rsync -a /pbx/ ~/backup/pbx-dir.bkp.$(date +%Y%m%d-%H.%M.%S)

echo 'Running APP container: ' $podname-app
### create app container - run attached to 
podman create --name $podname-app --pod $podname \
    --runtime=/usr/lib/cri-o-runc/sbin/runc \
    -v /$podname/data:/data \
    -v /$podname/logs:/var/log \
    -v /$podname/www:/var/www/html \
    -e RTP_START=18000 \
    -e RTP_FINISH=18200 \
    -e ENABLE_FAIL2BAN=TRUE \
    -e ENABLE_SSL=TRUE \
    -e ENABLE_ZABBIX=FALSE \
    -e ENABLE_XMPP=FALSE \
    -e UCP_FIRST=FALSE \
    -e FREEPBX_VERSION=15.0.17.26 \
    -e INSTALL_ADDITIONAL_MODULES="webrtc callforward findmefollow ringgroups cel" \
    -e DB_EMBEDDED=FALSE \
    -e DB_HOST=127.0.0.1 \
    -e DB_PORT=3306 \
    -e DB_NAME=asterisk \
    -e DB_USER=asterisk \
    -e DB_PASS=$MYSQLPWD \
    --cap-add=NET_ADMIN \
        al3nas/freepbx:$version

### remind to refresh signatures 
echo "Run this after it starts: podman exec -t $podname-app fwconsole ma refreshsignatures"
#podman attach $podname-app