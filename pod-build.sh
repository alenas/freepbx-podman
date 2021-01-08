podman build -t al3nas/freepbx:181 \
    --rm --memory 3g --memory-swap 3g \
    --cap-add=NET_ADMIN \
    --squash \
    -f Dockerfile .
