podman build -t al3nas/freepbx:182 \
    --rm \
    --cap-add=NET_ADMIN \
    --squash-all \
    -f Dockerfile .
