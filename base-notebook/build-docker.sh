#!/bin/sh

docker pull ubuntu:18.04

docker build . -t registry.graemes.com/graemes/jupyter-base-notebook:latest  
docker push registry.graemes.com/graemes/jupyter-base-notebook:latest

