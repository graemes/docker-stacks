#!/bin/bash

for NOTEBOOK in "base-notebook" "minimal-notebook" "scipy-notebook" "datascience-notebook" \
	        "all-notebook" "tensorflow-notebook" "r-notebook" \
		"pyspark-notebook" "all-spark-notebook"
do
	pushd ${NOTEBOOK}
	./build-docker.sh
	popd
done
