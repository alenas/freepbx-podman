podman build -t al3nas/freepbx:18.5 \
    --runtime=/usr/lib/cri-o-runc/sbin/runc \
    --security-opt seccomp=unconfined \
    --pull=true \
    --cap-add=NET_ADMIN \
    --squash \
    --format=docker \
    -f ../Dockerfile
