#!/bin/bash

NOTEBOOKS="base-notebook minimal-notebook scipy-notebook datascience-notebook tensorflow-notebook r-notebook pyspark-notebook all-notebook all-spark-notebook"

function build-all-cpu() {
  for NOTEBOOK in ${NOTEBOOKS}
  do
    pushd ${NOTEBOOK}
    ./build-docker-cpu.sh 
    popd
  done
}

function build-all-gpu() {
  for NOTEBOOK in ${NOTEBOOKS}
  do
    pushd ${NOTEBOOK}
    ./build-docker-gpu.sh 
    popd
  done
}

build-all-cpu &
build-all-gpu &
wait
docker-clean-unused.sh
