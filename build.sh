#!/bin/bash

set -x
set -e

# to test this script locally run the following command to enable linux/arm64 builds with docker:
# docker run --privileged --rm tonistiigi/binfmt --install all

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
docker run -v $PWD:/home --entrypoint "" concourse-arm-worker /bin/sh -c " \
  set -o errtrace -o pipefail -o errexit; \
  cp /home/concourse-worker.service /etc/systemd/system/; \
  tar -czf /home/artifacts/concourse_extracted.tar.gz /usr/local/concourse /etc/systemd/system/concourse-worker.service"

ls -lh artifacts
