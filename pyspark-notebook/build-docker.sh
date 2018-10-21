#!/bin/sh

BASE_REGISTRY="registry.graemes.com/graemes/jupyter"
BASE_CONTAINER=${BASE_REGISTRY}/"scipy-notebook"
BASE_OUTPUT=${BASE_REGISTRY}/"pyspark-notebook"
GPU_CONTAINER="${BASE_CONTAINER}:gpu"
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
