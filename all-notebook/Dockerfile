# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BUILD_CONTAINER=jupyter/datascience-notebook
FROM $BUILD_CONTAINER

LABEL maintainer="Graeme Seaton <graemes@github>"

# Set when building on Travis so that certain long-running build steps can
# be skipped to shorten build time.
ARG TEST_ONLY_BUILD

# Install Tensorflow
#RUN conda install --quiet --yes \
#    'tensorflow=1.13*' \
#    'keras=2.2*' && \
#    conda clean --all -f -y && \
#    fix-permissions $CONDA_DIR && \
#    fix-permissions /home/$NB_USER

# Install Tensorflow & watermark
#RUN conda install --quiet --yes \
#    'tensorflow=2.3.0' && \
#    conda clean --all -f -y && \
#    npm cache clean --force && \
#    rm -rf /home/$NB_USER/.cache/yarn && \
#    fix-permissions $CONDA_DIR && \
#    fix-permissions /home/$NB_USER

    #jupyter labextension install @jupyterlab/git && \
    #jupyter labextension install @jupyterlab/toc && \
# Install Tensorflow
RUN pip install --quiet --no-cache-dir \
    'tensorflow==2.3.0' && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
