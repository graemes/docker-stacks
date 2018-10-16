#!/bin/bash

pushd ./base-notebook/ ; ./build-docker.sh ; popd
pushd ./minimal-notebook/ ; ./build-docker.sh ; popd
<<<<<<< HEAD
#pushd ./minimal-notebook-gpu/ ; ./build-docker.sh ; popd
=======
>>>>>>> parent of dd9cd43... Merge components of 'batteries included' container into single file
pushd ./scipy-notebook/ ; ./build-docker.sh ; popd
pushd ./datascience-notebook/ ; ./build-docker.sh ; popd
#pushd ./ultracat-notebook/ ; ./build-docker.sh ; popd

#./examples/docker-compose/notebook/build.sh
