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

# NO `docker pull "${ROOT_IMAGE}"` here.
#
# The build below runs on the docker-container buildx driver, which has its own
# content store and never reads dockerd's image store -- so pulling the root
# image locally fetched a multi-GB parent that nothing then consulted, once per
# image-variant (22 times per weekly run). `--pull` on the build itself already
# guarantees a fresh base. Removing it also stops the local image store growing,
# which was the bulk of the non-cache disk usage the BuildKit gc budget has to
# work around.

# Build ONCE, apply every tag to that single build.
#
# This was a loop that ran a full `--no-cache` build per tag: identical context,
# identical work, different tag string. Measured on build-weekly 4889, that made
# 44 buildx invocations for 11 images x 2 variants -- 22 of them pure duplicates,
# on the stage accounting for 56% of the run.
#
# buildx accepts repeated -t and pushes all of them from one build, which is what
# chia-docker and PowerDNS-Admin already do. Collect the tags, then build.
TAG_ARGS=()
for TAG in "latest" "ubuntu${UBUNTU_VERSION}"; do
    TAG_NAME="${CONTAINER_TYPE:+${CONTAINER_TYPE}-}${TAG}"
    echo "Pushing: ${BASE_OUTPUT}:${TAG_NAME}"
    TAG_ARGS+=(-t "${BASE_OUTPUT}:${TAG_NAME}")
done

docker buildx build --no-cache --pull . \
    --platform linux/amd64 \
    --build-arg "BASE_IMAGE=${ROOT_IMAGE}" \
    --build-arg "ROOT_IMAGE=${ROOT_IMAGE}" \
    "${TAG_ARGS[@]}" \
    --push

echo "Done: ${BASE_REPOSITORY}"
