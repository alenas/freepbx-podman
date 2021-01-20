podman build -t al3nas/freepbx:181 \
    --rm \
    --cap-add=NET_ADMIN \
    --squash-all \
    -f Dockerfile .
