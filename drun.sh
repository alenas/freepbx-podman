docker run --name freepbx \
    -v pbx-data:/data \
    -v pbx-logs:/var/log \
    -v pbx-www:/var/www/html \
    -v pbx-db:/var/lib/mysql \
    -e HOSTNAME=voip.pir.lt \
    -e RTP_START=18000 \
    -e RTP_FINISH=18200 \
    -e ENABLE_FAIL2BAN=TRUE \
    -e ENABLE_SSL=TRUE \
    -e ENABLE_ZABBIX=FALSE \
    -e ENABLE_XMPP=FALSE \
    -e UCP_FIRST=FALSE \
    -e INSTALL_ADDITIONAL_MODULES=webrtc \
    -e DB_EMBEDDED=TRUE \
    --cap-add=NET_ADMIN \
    tiredofit/freepbx:latest