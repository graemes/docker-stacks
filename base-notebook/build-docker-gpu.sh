#!/bin/bash

source ./build-params

docker pull ${GPU_CONTAINER}

docker build . \
	--squash \
	-t ${GPU_OUTPUT} \
	--build-arg BASE_CONTAINER=${GPU_CONTAINER}
docker push ${GPU_OUTPUT}
