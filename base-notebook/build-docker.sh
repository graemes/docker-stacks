#!/bin/sh

BASE_REGISTRY="registry.graemes.com/graemes/jupyter"
BASE_CONTAINER="ubuntu:18.04"
BASE_OUTPUT=${BASE_REGISTRY}/"base-notebook"
GPU_CONTAINER=${BASE_REGISTRY}/"cuda:10.0-devel"
GPU_OUTPUT="${BASE_OUTPUT}:gpu"

docker pull ${BASE_CONTAINER}
docker pull ${GPU_CONTAINER}

docker build . \
    -t ${BASE_OUTPUT} \
    --build-arg BASE_CONTAINER=${BASE_CONTAINER}
docker push ${BASE_OUTPUT}

docker build . \
    -t ${GPU_OUTPUT} \
    --build-arg BASE_CONTAINER=${GPU_CONTAINER}
docker push ${GPU_OUTPUT}
