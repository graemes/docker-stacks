#!/bin/bash

pushd ./base-notebook/ ; ./build-docker.sh ; popd
pushd ./minimal-notebook/ ; ./build-docker.sh ; popd
pushd ./scipy-notebook/ ; ./build-docker.sh ; popd
pushd ./datascience-notebook/ ; ./build-docker.sh ; popd
pushd ./ultracat-notebook/ ; ./build-docker.sh ; popd

#./examples/docker-compose/notebook/build.sh
