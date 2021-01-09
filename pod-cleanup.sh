podman pod stop pbx
podman pod rm pbx
rm -f -r /pbx/data/*
rm -f -r /pbx/logs/*
rm -f -r /pbx/www/*
rm -f -r /pbx/db/*