echo "Stopping and disabling PBX services"
systemctl stop pod-pbx
systemctl disable pod-pbx
systemctl disable container-pbx-app
systemctl disable container-pbx-db

echo "Creating new PBX services"
podman generate systemd -f -n -t=30 pbx
mv -f *.service /etc/systemd/system/

echo "Enabling services"
systemctl enable pod-pbx
systemctl enable container-pbx-app
systemctl enable container-pbx-db

systemctl start pod-pbx