#!/bin/sh

BASE_REGISTRY="registry.graemes.com/graemes"
BASE_CONTAINER="jupyter-scipy-notebook"
OUTPUT_BASE="jupyter-datascience-notebook"

docker pull ${BASE_REGISTRY}/${BASE_CONTAINER}
docker pull ${BASE_REGISTRY}/${BASE_CONTAINER}:gpu

docker build . \
    -t ${BASE_REGISTRY}/${OUTPUT_BASE} \
    --build-arg BUILD_CONTAINER=${BASE_REGISTRY}/${BASE_CONTAINER}
docker push ${BASE_REGISTRY}/${OUTPUT_BASE}

docker build . \
    -t ${BASE_REGISTRY}/${OUTPUT_BASE}:gpu \
    --build-arg BUILD_CONTAINER=${BASE_REGISTRY}/${BASE_CONTAINER}:gpu
docker push ${BASE_REGISTRY}/${OUTPUT_BASE}:gpu

