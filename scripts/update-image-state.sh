#!/usr/bin/env bash
set -e

IMAGE="secure-app:local"

echo "Calculating image digest..."
DIGEST=$(docker inspect --format='{{.Id}}' ${IMAGE})

echo "${DIGEST}" > .image.digest
echo "Image state updated:"
cat .image.digest
