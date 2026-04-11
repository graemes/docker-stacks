#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly BUILD="${SCRIPT_DIR}/images/build-container.sh"

build_image() {
    local image="$1"
    local type="${2:-}"
    pushd "${SCRIPT_DIR}/images/${image}" > /dev/null
    "${BUILD}" ${type:+"$type"}
    popd > /dev/null
}

wait_pids() {
    local rc=0
    for pid in "$@"; do
        wait "$pid" || rc=$?
    done
    return "$rc"
}

# Wave 1: spine — each layer depends on the previous
for image in docker-stacks-foundation base-notebook minimal-notebook; do
    build_image "$image"     & cpu=$!
    build_image "$image" gpu & gpu=$!
    wait_pids "$cpu" "$gpu"
done

# Wave 2: fan-out from minimal-notebook
# julia and r-notebook are terminal; scipy feeds wave 3
build_image julia-notebook     &
build_image julia-notebook gpu &
build_image r-notebook         &
build_image r-notebook     gpu &
build_image scipy-notebook     & scipy_cpu=$!
build_image scipy-notebook gpu & scipy_gpu=$!
wait_pids "$scipy_cpu" "$scipy_gpu"  # only block on scipy; julia/r continue

# Wave 3: fan-out from scipy-notebook
# pyspark feeds wave 4; others are terminal
build_image datascience-notebook     &
build_image datascience-notebook gpu &
build_image pytorch-notebook         &
build_image pytorch-notebook     gpu &
build_image tensorflow-notebook      &
build_image tensorflow-notebook  gpu &
build_image pyspark-notebook         & pyspark_cpu=$!
build_image pyspark-notebook     gpu & pyspark_gpu=$!
wait_pids "$pyspark_cpu" "$pyspark_gpu"  # only block on pyspark

# Wave 4: all-spark depends on pyspark
build_image all-spark-notebook     &
build_image all-spark-notebook gpu &

# Wait for all remaining background jobs (julia, r, datascience, pytorch, tensorflow, all-spark)
wait

"${HOME}/bin/docker-clean-all.sh"
