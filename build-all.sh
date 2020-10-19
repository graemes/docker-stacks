#!/bin/bash

NOTEBOOKS="base-notebook minimal-notebook scipy-notebook datascience-notebook tensorflow-notebook r-notebook pyspark-notebook all-notebook all-spark-notebook"

for NOTEBOOK in ${NOTEBOOKS}
do
	pushd ${NOTEBOOK}
	./build-docker-cpu.sh
	popd
done

docker-clean-unused.sh

for NOTEBOOK in ${NOTEBOOKS}
do
	pushd ${NOTEBOOK}
	./build-docker-gpu.sh
	popd
done
