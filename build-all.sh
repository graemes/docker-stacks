#!/bin/bash

set -euo pipefail

NOTEBOOKS="docker-stacks-foundation base-notebook minimal-notebook r-notebook julia-notebook scipy-notebook datascience-notebook pytorch-notebook tensorflow-notebook pyspark-notebook all-spark-notebook"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

build-all-cpu() {
  for NOTEBOOK in ${NOTEBOOKS}; do
    pushd "${SCRIPT_DIR}/images/${NOTEBOOK}"
    "${SCRIPT_DIR}/images/build-container.sh"
    popd
  done
}

build-all-gpu() {
  for NOTEBOOK in ${NOTEBOOKS}; do
    pushd "${SCRIPT_DIR}/images/${NOTEBOOK}"
    "${SCRIPT_DIR}/images/build-container.sh" gpu
    popd
  done
}

build-all-cpu &
BG_PID1=$!

build-all-gpu &
BG_PID2=$!

wait "$BG_PID1"
wait "$BG_PID2"

"${HOME}/bin/docker-clean-all.sh"
