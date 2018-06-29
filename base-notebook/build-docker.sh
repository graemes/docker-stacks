#!/bin/sh

docker build . -t registry.graemes.com/graemes/jupyter-base-notebook:latest  
docker push registry.graemes.com/graemes/jupyter-base-notebook:latest

