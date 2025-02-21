#!/bin/bash

source ./build-params

# List of tags to apply
TAGS=("latest" "ubuntu22.04")

docker pull ${ROOT_IMAGE}

echo "Base Container: ${ROOT_IMAGE}"
echo "Base Output: ${BASE_OUTPUT}"
echo "Base Output - cloud: ${BASE_OUTPUT_CLOUD}"

# Build the Docker image for multiple platforms and tag it with multiple tags
for TAG in "${TAGS[@]}"; do
    docker buildx build . \
		--platform linux/amd64 \
		--build-arg ROOT_IMAGE=${ROOT_IMAGE} \
		-t ${BASE_OUTPUT}:${TAG} \
		-t ${BASE_OUTPUT_CLOUD}:${TAG} \
		--push
done

echo "Docker images pushed successfully!"
exit 0