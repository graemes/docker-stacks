#!/bin/bash

source ./build-params

docker pull ${BASE_CONTAINER}

echo "Base Container: ${ROOT_CONTAINER}"
echo "Base Output: ${BASE_OUTPUT}"
echo "Base Output - cloud: ${BASE_OUTPUT_CLOUD}"

docker build . \
	--squash \
	-t ${BASE_OUTPUT} \
	-t ${BASE_OUTPUT_CLOUD} \
	--build-arg ROOT_CONTAINER=${ROOT_CONTAINER}

docker push ${BASE_OUTPUT}
docker push ${BASE_OUTPUT_CLOUD}

