#!/bin/sh

. ${HOME}/build/tools/build-params

BASE_REGISTRY="registry.graemes.com/graemes"
BASE_CONTAINER=${BASE_REGISTRY}/"ubuntubuild:18.04"
BASE_OUTPUT=${BASE_REGISTRY}/"jupyter/base-notebook"
GPU_CONTAINER=${BASE_REGISTRY}/"nvidia-cuda:${CUDA_VERSION}-devel"
GPU_OUTPUT="${BASE_OUTPUT}:gpu"

docker pull ${BASE_CONTAINER}
docker pull ${GPU_CONTAINER}

docker build . \
	--squash \
	-t ${BASE_OUTPUT} \
	--build-arg BASE_CONTAINER=${BASE_CONTAINER}
docker push ${BASE_OUTPUT}

docker build . \
	--squash \
	-t ${GPU_OUTPUT} \
	--build-arg BASE_CONTAINER=${GPU_CONTAINER}
docker push ${GPU_OUTPUT}
