#!/bin/bash

# Build and push a single Jupyter Docker Stacks image.
# Must be run from the image directory (which contains build-params).
#
# Usage: build-container.sh [gpu]
#   gpu — build the GPU variant (uses GPU_ROOT_IMAGE instead of ROOT_IMAGE)

set -euo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }

CONTAINER_TYPE="${1:-}"
[[ -z "$CONTAINER_TYPE" || "$CONTAINER_TYPE" == "gpu" ]] || \
    die "Invalid argument '${CONTAINER_TYPE}'. Only 'gpu' or no argument is accepted."

[[ -f "./build-params" ]] || die "'build-params' not found in $(pwd)"

# shellcheck disable=SC1091
source ./build-params

# Resolve root image
if [[ "$CONTAINER_TYPE" == "gpu" ]]; then
    ROOT_IMAGE="${GPU_ROOT_IMAGE:-${BASE_REGISTRY}/${BASE_IMAGE}:gpu-latest}"
else
    ROOT_IMAGE="${ROOT_IMAGE:-${BASE_REGISTRY}/${BASE_IMAGE}:latest}"
fi

BASE_OUTPUT="${BASE_OUTPUT:-${BASE_REGISTRY}/${BASE_REPOSITORY}}"

echo "Container Type: ${CONTAINER_TYPE:-cpu}"
echo "Root Image:     ${ROOT_IMAGE}"
echo "Output:         ${BASE_OUTPUT}"

docker pull "${ROOT_IMAGE}"

for TAG in "latest" "ubuntu${UBUNTU_VERSION}"; do
    TAG_NAME="${CONTAINER_TYPE:+${CONTAINER_TYPE}-}${TAG}"
    echo "Pushing: ${BASE_OUTPUT}:${TAG_NAME}"
    docker buildx build . \
        --platform linux/amd64 \
        --build-arg "BASE_IMAGE=${ROOT_IMAGE}" \
        --build-arg "ROOT_IMAGE=${ROOT_IMAGE}" \
        -t "${BASE_OUTPUT}:${TAG_NAME}" \
        --push
done

echo "Done: ${BASE_REPOSITORY}"
