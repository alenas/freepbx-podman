podman build -t al3nas/freepbx:182 \
    --runtime=/usr/lib/cri-o-runc/sbin/runc \
    --pull=true \
    --rm \
    --cap-add=NET_ADMIN \
    --squash-all \
    -f Dockerfile .
