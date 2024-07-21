#!/bin/bash

source ./build-params

docker pull ${GPU_CONTAINER}

echo "GPU Container: ${GPU_CONTAINER}"
echo "GPU Output: ${GPU_OUTPUT}"
echo "GPU Output - cloud: ${GPU_OUTPUT_CLOUD}"

docker build . \
	--squash \
	-t ${GPU_OUTPUT} \
	-t ${GPU_OUTPUT_CLOUD} \
	--build-arg ROOT_CONTAINER=${GPU_CONTAINER}

docker push ${GPU_OUTPUT}
docker push ${GPU_OUTPUT_CLOUD}
