podman build -t al3nas/freepbx:18.5 \
    --security-opt seccomp=unconfined \
    --pull=true \
    --cap-add=NET_ADMIN \
    --squash \
    --format=docker \
    -f ../Dockerfile
