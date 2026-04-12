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
    local rc=0 pid_rc
    for pid in "$@"; do
        pid_rc=0
        wait "$pid" || pid_rc=$?
        if (( pid_rc != 0 )); then
            echo "ERROR: PID $pid exited with rc=$pid_rc" >&2
            rc=$pid_rc
        fi
    done
    return "$rc"
}

all_pids=()
overall_rc=0

# Wave 1: spine — each layer depends on the previous
for image in docker-stacks-foundation base-notebook minimal-notebook; do
    build_image "$image"     & cpu=$!
    build_image "$image" gpu & gpu=$!
    wait_pids "$cpu" "$gpu" || overall_rc=$?
done

# Wave 2: fan-out from minimal-notebook — track ALL pids
# julia and r-notebook are terminal; scipy feeds wave 3
build_image julia-notebook     & all_pids+=($!)
build_image julia-notebook gpu & all_pids+=($!)
build_image r-notebook         & all_pids+=($!)
build_image r-notebook     gpu & all_pids+=($!)
build_image scipy-notebook     & scipy_cpu=$!; all_pids+=($!)
build_image scipy-notebook gpu & scipy_gpu=$!; all_pids+=($!)
wait_pids "$scipy_cpu" "$scipy_gpu" || overall_rc=$?

# Wave 3: fan-out from scipy-notebook — track ALL pids
# pyspark feeds wave 4; others are terminal
build_image datascience-notebook     & all_pids+=($!)
build_image datascience-notebook gpu & all_pids+=($!)
build_image pytorch-notebook         & all_pids+=($!)
build_image pytorch-notebook     gpu & all_pids+=($!)
build_image tensorflow-notebook      & all_pids+=($!)
build_image tensorflow-notebook  gpu & all_pids+=($!)
build_image pyspark-notebook         & pyspark_cpu=$!; all_pids+=($!)
build_image pyspark-notebook     gpu & pyspark_gpu=$!; all_pids+=($!)
wait_pids "$pyspark_cpu" "$pyspark_gpu" || overall_rc=$?

# Wave 4: all-spark depends on pyspark
build_image all-spark-notebook     & all_pids+=($!)
build_image all-spark-notebook gpu & all_pids+=($!)

# Wait for ALL remaining background jobs (julia, r, datascience, pytorch, tensorflow, all-spark)
# Per-PID wait propagates failures; bare 'wait' swallows them.
for pid in "${all_pids[@]}"; do
    wait "$pid" 2>/dev/null || overall_rc=$?
done

"${HOME}/bin/docker-clean-all.sh"
exit "$overall_rc"
