# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
#FROM jupyter/scipy-notebook
FROM registry.graemes.com/graemes/jupyter-datascience-notebook

LABEL maintainer="Graeme Seaton <graemes@github>"

# Set when building on Travis so that certain long-running build steps can
# be skipped to shorten build time.
ARG TEST_ONLY_BUILD

USER root

# Add local files as late as possible to avoid cache busting
COPY start-singleuser.sh /usr/local/bin/
RUN fix-permissions /etc/jupyter/

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

