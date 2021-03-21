podman rmi al3nas/freepbx:latest
podman build -t al3nas/freepbx:latest \
    --runtime=/usr/lib/cri-o-runc/sbin/runc \
    --cap-add=NET_ADMIN \
    --squash \
    --format=docker \
    -f Dockerfile
