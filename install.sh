podname=pbx
version=latest

### check if install is already there
if [ -f set-env-pwd.sh ]; then
    echo 'Seems like there is an existing install, exiting!'
    exit 1
fi

mkdir -p /$podname/data
mkdir -p /$podname/www
mkdir -p /$podname/logs

if [ ! -f set-env-pwd.sh ]; then
    echo 'Generating random MySQL passwords and saving to set-env.pwd.sh'
    . generate-mysql-pwd.sh
else
    . set-env-pwd.sh
fi

echo 'Creating pod: ' $podname
### create pod
podman pod create -n $podname --hostname voip.pir.lt \
    --network bridge \
    -p 80:80/tcp -p 443:443/tcp \
    -p 5060:5060/tcp -p 5060:5060/udp -p 5061:5061/tcp -p 5061:5061/udp \
    -p 8089:8089 \
    -p 18000-18200:18000-18200/udp

echo 'Starting pod: ' $podname
podman pod start pbx

echo 'Running DB container: ' $podname-db
### create db container
podman run -d --name $podname-db --pod $podname \
    -v $podname-db:/var/lib/mysql \
    -e MYSQL_DATABASE=asterisk \
    -e MYSQL_USER=asterisk \
    -e MYSQL_PASSWORD=$MYSQLPWD \
    -e MYSQL_ROOT_PASSWORD=$MYSQLROOTPWD \
        mariadb:10.5

### create app container - run and then attach to
. update.sh $podname $version
