mysqlpwd=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()' | fold -w 16 | head -n 1)
mysqlrootpwd=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()' | fold -w 24 | head -n 1)

echo 'MySQL: ' $mysqlpwd '    ROOT : ' $mysqlrootpwd > pwd.txt

### create pod
podman pod stop pbx
podman pod create -n pbx --hostname voip.pir.lt \
    -p 80:80/tcp -p 443:443/tcp \
    -p 5060:5060/tcp -p 5060:5060/udp -p 5061:5061/tcp -p 5061:5061/udp \
    -p 8089:8089 \
    -p 18000-18200:18000-18200/udp \
    --replace
podman pod start pbx

### create db container
podman run -d --name freepbx-db --pod pbx \
    -v /pbx/db:/var/lib/mysql \
    -v /pbx/dbbackup:/backup \
    -e MYSQL_ROOT_PASSWORD=$mysqlrootpwd \
    -e MYSQL_DATABASE=asterisk \
    -e MYSQL_USER=asterisk \
    -e MYSQL_PASSWORD=$mysqlpwd \
    --replace \
    tiredofit/mariadb:latest

### create app container
podman run --name freepbx --pod pbx \
    -v /pbx/data:/data:Z \
    -v /pbx/logs:/var/log:Z \
    -v /pbx/www:/var/www/html:Z \
    -e RTP_START=18000 \
    -e RTP_FINISH=18200 \
    -e ENABLE_FAIL2BAN=TRUE \
    -e ENABLE_SSL=TRUE \
    -e ENABLE_ZABBIX=FALSE \
    -e ENABLE_XMPP=FALSE \
    -e UCP_FIRST=FALSE \
    -e INSTALL_ADDITIONAL_MODULES=webrtc \
    -e DB_EMBEDDED=FALSE \
    -e DB_HOST=127.0.0.1 \
    -e DB_PORT=3306 \
    -e DB_NAME=asterisk \
    -e DB_USER=asterisk \
    -e DB_PASS=$mysqlpwd \
    --replace \
    --cap-add=NET_ADMIN \
    al3nas/freepbx:181





