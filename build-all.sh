#!/bin/bash

for NOTEBOOK in "base_notebook" "minimal-notebook" "scipy-notebook" "datascience-notebook" \
	        "ultracat-notebook" "tensorflow-notebook" "r-notebook" \
		"pyspark-notebook" "all-spark-notebook"
do
	pushd ${NOTEBOOK}
	./build-docker.sh
	popd
done

#pushd ./base-notebook/ ; ./build-docker.sh ; popd
#pushd ./minimal-notebook/ ; ./build-docker.sh ; popd
#pushd ./scipy-notebook/ ; ./build-docker.sh ; popd
#pushd ./datascience-notebook/ ; ./build-docker.sh ; popd
#pushd ./ultracat-notebook/ ; ./build-docker.sh ; popd
#pushd ./r-notebook/ ; ./build-docker.sh ; popd
#pushd ./pyspark-notebook/ ; ./build-docker.sh ; popd
#pushd ./allspark-notebook/ ; ./build-docker.sh ; popd

#./examples/docker-compose/notebook/build.sh
