#!/bin/sh

docker pull nvidia/cuda:9.1-base
docker pull nvidia/cuda:9.1-runtime
docker pull nvidia/cuda:9.1-devel
docker pull registry.graemes.com/graemes/jupyter-base-notebook:latest

docker build . -t registry.graemes.com/graemes/jupyter-minimal-notebook:latest  
docker push registry.graemes.com/graemes/jupyter-minimal-notebook:latest

