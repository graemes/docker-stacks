#!/bin/bash

source ./build-params

docker pull ${GPU_CONTAINER}

docker build . \
	--squash \
	-t ${GPU_OUTPUT} \
	-f Dockerfile.gpu \
	--build-arg BUILD_CONTAINER=${GPU_CONTAINER}

docker push ${GPU_OUTPUT}
