#!/bin/sh

BASE_REGISTRY="registry.graemes.com/graemes"
BASE_CONTAINER="jupyter-minimal-notebook"
OUTPUT_BASE="jupyter-scipy-notebook"

docker pull ${BASE_REGISTRY}/${BASE_CONTAINER}:latest
docker pull ${BASE_REGISTRY}/${BASE_CONTAINER}-gpu:latest

docker build . \
    -t ${BASE_REGISTRY}/${OUTPUT_BASE}:latest
docker push ${BASE_REGISTRY}/${OUTPUT_BASE}:latest

docker build . \
    -t ${BASE_REGISTRY}/${OUTPUT_BASE}-gpu:latest \
    --build-arg BUILD_CONTAINER=${BASE_REGISTRY}/${BASE_CONTAINER}-gpu:latest
docker push ${BASE_REGISTRY}/${OUTPUT_BASE}-gpu:latest


