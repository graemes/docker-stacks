#!/bin/sh

docker pull registry.graemes.com/graemes/jupyter-base-notebook:latest

docker build . -t registry.graemes.com/graemes/jupyter-minimal-notebook-gpu:latest  
docker push registry.graemes.com/graemes/jupyter-minimal-notebook-gpu:latest