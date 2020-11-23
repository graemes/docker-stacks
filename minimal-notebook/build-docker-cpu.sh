#!/bin/bash

source ./build-params

docker pull ${BASE_CONTAINER}

iecho "Base container: ${BASE_CONTAINER}"
echo "Base Output: ${BASE_OUTPUT}"
echo "Base Output - cloud: ${BASE_OUTPUT_CLOUD}"

docker build . \
       --squash \
       -t ${BASE_OUTPUT} \
       -t ${BASE_OUTPUT_CLOUD} \
       --build-arg BASE_CONTAINER=${BASE_CONTAINER}

docker push ${BASE_OUTPUT}
docker push ${BASE_OUTPUT_CLOUD}
