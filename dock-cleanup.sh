docker stop freepbx-db
docker stop freepbx
docker rm freepbx-db
docker rm freepbx
rm -f -r /pbx/data/*
rm -f -r /pbx/logs/*
rm -f -r /pbx/www/*
rm -f -r /pbx/db/*

