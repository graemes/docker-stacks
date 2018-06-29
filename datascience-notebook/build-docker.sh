#!/bin/sh

docker pull registry.graemes.com/graemes/jupyter-scipy-notebook:latest

docker build . -t registry.graemes.com/graemes/jupyter-datascience-notebook:latest  
docker push registry.graemes.com/graemes/jupyter-datascience-notebook:latest

