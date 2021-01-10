echo 'MySQL: ' $MYSQLPWD '    ROOT : ' $MYSQLROOTPWD

### create db container
docker run -d --name freepbx-db \
    -v asterisk-db-181:/var/lib/mysql \
    -v /pbx/dbbackup:/backup \
    -e MYSQL_ROOT_PASSWORD=$MYSQLROOTPWD \
    -e MYSQL_DATABASE=asterisk \
    -e MYSQL_USER=asterisk \
    -e MYSQL_PASSWORD=$MYSQLPWD \
    --network pbx-net \
    tiredofit/mariadb:latest

### create app container
docker run --name freepbx \
    --hostname voip.pir.lt \
    -v /pbx/data:/data \
    -v /pbx/logs:/var/log \
    -v /pbx/www:/var/www/html \
    -p 80:80/tcp -p 443:443/tcp \
    -p 5060:5060/tcp -p 5060:5060/udp -p 5061:5061/tcp -p 5061:5061/udp \
    -p 8089:8089 \
    -p 18000-18200:18000-18200/udp \
    -e RTP_START=18000 \
    -e RTP_FINISH=18200 \
    -e ENABLE_FAIL2BAN=TRUE \
    -e ENABLE_SSL=TRUE \
    -e ENABLE_ZABBIX=FALSE \
    -e ENABLE_XMPP=FALSE \
    -e UCP_FIRST=FALSE \
    -e FREEPBX_VERSION=15.0.17.14 \
    -e INSTALL_ADDITIONAL_MODULES=webrtc \
    -e DB_EMBEDDED=FALSE \
    -e DB_HOST=freepbx-db \
    -e DB_PORT=3306 \
    -e DB_NAME=asterisk \
    -e DB_USER=asterisk \
    -e DB_PASS=$MYSQLPWD \
    --cap-add=NET_ADMIN --cap-add=SYS_ADMIN \
    --network pbx-net \
    al3nas/freepbx:181





