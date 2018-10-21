#!/bin/sh

BASE_REGISTRY="registry.graemes.com/graemes/jupyter"
BASE_CONTAINER=${BASE_REGISTRY}/"datascience-notebook"
BASE_OUTPUT=${BASE_REGISTRY}/"all-notebook"
GPU_CONTAINER="${BASE_CONTAINER}:gpu"
GPU_OUTPUT="${BASE_OUTPUT}:gpu"

docker pull ${BASE_CONTAINER}
docker pull ${GPU_CONTAINER}

docker build . \
    -t ${BASE_OUTPUT} \
    --build-arg BUILD_CONTAINER=${BASE_CONTAINER}
docker push ${BASE_OUTPUT}

docker build . \
    -t ${GPU_OUTPUT} \
    -f Dockerfile.gpu \
    --build-arg BUILD_CONTAINER=${GPU_CONTAINER}
docker push ${GPU_OUTPUT}
