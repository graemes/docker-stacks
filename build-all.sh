#!/bin/bash

NOTEBOOKS="docker-stacks-foundation base-notebook minimal-notebook r-notebook julia-notebook scipy-notebook datascience-notebook pytorch-notebook tensorflow-notebook pyspark-notebook all-spark-notebook"
#NOTEBOOKS="docker-stacks-foundation"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function build-all-cpu() {
  for NOTEBOOK in ${NOTEBOOKS}
  do
    pushd images/${NOTEBOOK}
    ${SCRIPT_DIR}/images/build-container.sh 
    #docker system prune -f
    popd
  done
}

function build-all-gpu() {
  for NOTEBOOK in ${NOTEBOOKS}
  do
    pushd images/${NOTEBOOK}
    ${SCRIPT_DIR}/images/build-container.sh gpu
    #docker system prune -f
    popd
  done
}

build-all-cpu &
BG_PID1=$!

build-all-gpu &
BG_PID2=$!

wait $BG_PID1
wait $BG_PID2

docker-clean-all.sh

#docker buildx prune -af
