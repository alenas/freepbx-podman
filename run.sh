podname=pbx

mkdir -p /$podname/data
mkdir -p /$podname/www
mkdir -p /$podname/logs

. cleanup.sh $podname

### create pod
podman pod create -n $podname --hostname voip.pir.lt \
    --network bridge \
    -p 80:80/tcp -p 443:443/tcp \
    -p 5060:5060/tcp -p 5060:5060/udp -p 5061:5061/tcp -p 5061:5061/udp \
    -p 8089:8089 \
    -p 18000-18200:18000-18200/udp

podman pod start pbx

### create db container
podman run -d --name $podname-db --pod $podname \
    -v $podname-db:/var/lib/mysql \
    -e MYSQL_DATABASE=asterisk \
    -e MYSQL_USER=asterisk \
    -e MYSQL_PASSWORD=$MYSQLPWD \
    -e MYSQL_ROOT_PASSWORD=$MYSQLROOTPWD \
        mariadb:10.5

### create app container - run attached to 
podman run --name $podname-app --pod $podname \
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
    -e FREEPBX_VERSION=15.0.17.12 \
    -e INSTALL_ADDITIONAL_MODULES=webrtc \
    -e DB_EMBEDDED=FALSE \
    -e DB_HOST=127.0.0.1 \
    -e DB_PORT=3306 \
    -e DB_NAME=asterisk \
    -e DB_USER=asterisk \
    -e DB_PASS=$MYSQLPWD \
    --systemd=true \
        al3nas/freepbx:w176





