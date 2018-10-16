#!/bin/sh

docker pull ubuntu:18.04

docker build . -t registry.graemes.com/graemes/jupyter-base-notebook:latest  
docker push registry.graemes.com/graemes/jupyter-base-notebook:latest

BASE_REGISTRY="registry.graemes.com/graemes"
BASE_CONTAINER="ubuntu:18.04"
GPU_CONTAINER="cuda:10.0-devel"
OUTPUT_BASE="jupyter-base-notebook"

docker pull ${BASE_CONTAINER}
docker pull ${BASE_REGISTRY}/${GPU_CONTAINER}

docker build . \
    -t ${BASE_REGISTRY}/${OUTPUT_BASE} \
    --build-arg BUILD_CONTAINER=${BASE_CONTAINER}
docker push ${BASE_REGISTRY}/${OUTPUT_BASE}

docker build . \
    -t ${BASE_REGISTRY}/${OUTPUT_BASE}:gpu \
    --build-arg BUILD_CONTAINER=${BASE_REGISTRY}/${GPU_CONTAINER}
docker push ${BASE_REGISTRY}/${OUTPUT_BASE}:gpu
