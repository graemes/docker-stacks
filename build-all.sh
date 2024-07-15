#!/bin/bash

NOTEBOOKS="docker-stacks-foundation base-notebook minimal-notebook scipy-notebook r-notebook julia-notebook datascience-notebook tensorflow-notebook pyspark-notebook all-spark-notebook"

function build-all-cpu() {
  for NOTEBOOK in ${NOTEBOOKS}
  do
    pushd images/${NOTEBOOK}
    ./build-docker-cpu.sh 
    #docker system prune -f
    popd
  done
}

function build-all-gpu() {
  for NOTEBOOK in ${NOTEBOOKS}
  do
    pushd images/${NOTEBOOK}
    ./build-docker-gpu.sh 
    #docker system prune -f
    popd
  done
}

# build-all-cpu &
# build-all-gpu &
wait

build-all-cpu
docker-clean-unused.sh
build-all-gpu
docker-clean-unused.sh

#docker buildx prune -af
