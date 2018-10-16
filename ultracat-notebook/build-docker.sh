#!/bin/sh

BASE_REGISTRY="registry.graemes.com/graemes"
BASE_CONTAINER="jupyter-datascience-notebook"
OUTPUT_BASE="jupyter-ultracat-notebook"

docker pull ${BASE_REGISTRY}/${BASE_CONTAINER}
docker pull ${BASE_REGISTRY}/${BASE_CONTAINER}:gpu

docker build . \
    -t ${BASE_REGISTRY}/${OUTPUT_BASE} \
    --build-arg BUILD_CONTAINER=${BASE_REGISTRY}/${BASE_CONTAINER}
docker push ${BASE_REGISTRY}/${OUTPUT_BASE}

docker build . \
    -t ${BASE_REGISTRY}/${OUTPUT_BASE}:gpu \
    -f Dockerfile.dev \
    --build-arg BUILD_CONTAINER=${BASE_REGISTRY}/${BASE_CONTAINER}:gpu
docker push ${BASE_REGISTRY}/${OUTPUT_BASE}:gpu