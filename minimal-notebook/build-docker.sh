#!/bin/sh

BASE_REGISTRY="registry.graemes.com/graemes"
BASE_CONTAINER="jupyter-base-notebook"
OUTPUT_BASE="jupyter-minimal-notebook"

docker pull ${BASE_REGISTRY}/${BASE_CONTAINER}
docker pull ${BASE_REGISTRY}/${BASE_CONTAINER}:gpu

docker build . \
    -t ${BASE_REGISTRY}/${OUTPUT_BASE} \
    --build-arg BASE_CONTAINER=${BASE_REGISTRY}/${BASE_CONTAINER}
docker push ${BASE_REGISTRY}/${OUTPUT_BASE}

docker build . \
    -t ${BASE_REGISTRY}/${OUTPUT_BASE}:gpu \
    --build-arg BASE_CONTAINER=${BASE_REGISTRY}/${BASE_CONTAINER}:gpu
docker push ${BASE_REGISTRY}/${OUTPUT_BASE}:gpu

