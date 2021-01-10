podname=izx

mkdir -p /$podname/data
mkdir -p /$podname/www
mkdir -p /$podname/asterisk

### create pod
podman pod create -n $podname --hostname voip.pir.lt \
    --network host
    # -p 80:80/tcp -p 443:443/tcp \
    # -p 5060:5060/tcp -p 5060:5060/udp -p 5061:5061/tcp -p 5061:5061/udp \
    # -p 8089:8089 \
    # -p 18000-18200:18000-18200/udp

podman pod start $podname

### create db container
podman run -d --name $podname-db --pod $podname \
    -v $podname-db:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=$MYSQLROOTPWD \
    -e MYSQL_USER=asterisk \
    -e MYSQL_PASSWORD=$MYSQLPWD \
        mariadb:10.5

### create app container
podman run --name $podname-pbx --pod $podname \
    -e MYSQL_SERVER=127.0.0.1 \
    -e MYSQL_DATABASE=asterisk \
    -e MYSQL_USER=asterisk \
    -e MYSQL_PASSWORD=$MYSQLPWD \
    -e MYSQL_ROOT_PASSWORD=$MYSQLROOTPWD \
    -e APP_FQDN=voip.pir.lt \
    -e LETSENCRYPT_ENABLED=true \
    -e FREEPBX_FREEPBX_SYSTEM_IDENT=PIR-VOIP \
    -e FREEPBX_AS_DISPLAY_READONLY_SETTINGS=0 \
    -e FREEPBX_AS_OVERRIDE_READONLY=0 \
    -e FREEPBX_TONEZONE=lt \
    -e FREEPBX_PHPTIMEZONE=Europe/Vilnius \
    -e APP_DATA=/data \
    -e APP_PORT_PJSIP=5060 \
    -e APP_PORT_SIP=5160 \
    -e APP_PORT_RTP_START=18000 \
    -e APP_PORT_RTP_END=18200 \
    -e ASTERISK_ENABLED=true \
    -e ZABBIX_ENABLED=false \
    -e FREEPBX_MODULES_EXTRA='soundlang callrecording cdr conferences customappsreg featurecodeadmin infoservices logfiles music manager arimanager filestore recordings announcement asteriskinfo backup callforward callwaiting daynight calendar certman cidlookup contactmanager donotdisturb findmefollow iaxsettings miscapps miscdests ivr parking phonebook presencestate printextensions queues cel timeconditions pm2 webrtc' \
    -e FREEPBX_BRAND_IMAGE_TANGO_LEFT=images/1.png \
    -e FREEPBX_BRAND_IMAGE_FREEPBX_FOOT=images/2.png \
    -e FREEPBX_BRAND_IMAGE_SPONSOR_FOOT=images/pir.png \
    -e FREEPBX_BRAND_FREEPBX_ALT_LEFT=FreePBX \
    -e FREEPBX_BRAND_FREEPBX_ALT_FOOT=FreePBX® \
    -e FREEPBX_BRAND_SPONSOR_ALT_FOOT=www.pir.lt \
    -e FREEPBX_BRAND_IMAGE_FREEPBX_LINK_LEFT=http://www.freepbx.org \
    -e FREEPBX_BRAND_IMAGE_FREEPBX_LINK_FOOT=http://www.freepbx.org \
    -e FREEPBX_BRAND_IMAGE_SPONSOR_LINK_FOOT=http://pir.lt \
    -v /$podname/data:/data \
    -v /$podname/www:/var/www \
    -v /$podname/asterisk:/etc/asterisk \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        izdock/izpbx-asterisk:latest





