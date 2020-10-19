#!/bin/bash

source ./build-params

docker pull ${BASE_CONTAINER}

docker build . \
	--squash \
	-t ${BASE_OUTPUT} \
	--build-arg BASE_CONTAINER=${BASE_CONTAINER}

docker push ${BASE_OUTPUT}
