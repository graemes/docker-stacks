# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BUILD_CONTAINER=jupytper/datascience-notebook
FROM $BUILD_CONTAINER

LABEL maintainer="Graeme Seaton <graemes@github>"

# Set when building on Travis so that certain long-running build steps can
# be skipped to shorten build time.
ARG TEST_ONLY_BUILD

# Install Tensorflow
USER $NB_UID

RUN conda install --quiet --yes \
    'tensorflow=1.5*' \
    'keras=2.1*' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

