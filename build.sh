#!/bin/bash

set -x
set -e

docker build --build-arg http_proxy --build-arg https_proxy \
  -t registry-image . \
  -f Dockerfile-registry-image
docker create --name registry-image registry-image
mkdir -p resource-types/registry-image
docker export registry-image | gzip \
  > resource-types/registry-image/rootfs.tgz
docker rm -v registry-image
docker build -t concourse-arm-worker .

# Extract compiled binaries
docker run -it -v $PWD:/home --entrypoint "" concourse-arm-worker /bin/sh -c "tar -czf /home/concourse_extracted.tar.gz /usr/local/concourse"
