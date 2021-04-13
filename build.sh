#!/bin/bash

set -x
set -e

docker buildx build \
  --platform linux/arm64 \
  --load \
  --build-arg http_proxy --build-arg https_proxy \
  -t registry-image . \
  -f Dockerfile-registry-image

docker create --name registry-image registry-image
mkdir -p resource-types/registry-image
docker export registry-image | gzip \
  > resource-types/registry-image/rootfs.tgz
docker rm -v registry-image

docker buildx build \
  --platform linux/arm64 \
  --load \
  -t concourse-arm-worker .

# create artifacts folder
mkdir -p artifacts

# Extract compiled binaries
docker run -it -v $PWD:/home --entrypoint "" concourse-arm-worker /bin/sh -c "tar -czf /home/artifacts/concourse_extracted.tar.gz /usr/local/concourse"

ls -lh artifacts
