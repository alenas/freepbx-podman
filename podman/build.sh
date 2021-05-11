podman build -t al3nas/freepbx:184 \
    --runtime=/usr/lib/cri-o-runc/sbin/runc \
    --pull=true \
    --cap-add=NET_ADMIN \
    --squash \
    --format=docker \
    -f ../Dockerfile
