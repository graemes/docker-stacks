# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_IMAGE=$REGISTRY/$OWNER/scipy-notebook
FROM $BASE_IMAGE

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# R pre-requisites
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Julia dependencies
# install Julia packages in /opt/julia instead of ${HOME}
# Julia compiles every package once per CPU target, so this list multiplies
# precompilation time directly (~158s of the ~395s julia setup step).
#
# Measured 2026-08-10 on the nodes jupyterhub actually schedules singleuser pods
# onto (namshub, label app-node=true):
#   k8sworker07  AMD Threadripper 2950X   avx avx2 fma sse4_2
#   k8sworker08  Intel i7-7700            avx avx2 fma sse4_2
#   k8sworker09  Intel i7-9700            avx avx2 fma sse4_2
#
# None has avx512f, so upstream's x86-64-v4 target produces code that cannot run
# on any of them, and sandybridge is redundant when all three do AVX2. haswell
# covers the real hardware; generic remains the portable fallback.
#
# This is a performance tradeoff, not a correctness one -- Julia selects the best
# matching variant, so the image still runs anywhere, just without a target-
# specific build. Re-measure this list if the app-node hardware changes.
ENV JULIA_CPU_TARGET="generic;haswell,-rdrnd,base(1)"

ENV JULIA_DEPOT_PATH=/opt/julia \
    JULIA_PKGDIR=/opt/julia

# Setup Julia
RUN /opt/setup-scripts/setup_julia.py

# macOS Rosetta virtualization creates junk directory which gets owned by root further up.
# It'll get re-created, but as USER runner after the next directive so hopefully should not cause permission issues.
#
# More info: https://github.com/jupyter/docker-stacks/issues/2296
# hadolint ignore=DL3059
RUN rm -rf "/home/${NB_USER}/.cache/"

USER ${NB_UID}

# Setup IJulia kernel & other packages
#
# Timeout for the same reason as julia-notebook: setup-julia-packages.bash runs
# Pkg.update() and Pkg.precompile() unpinned on every --no-cache build, so an
# upstream Julia or package release can hang it indefinitely with nothing else in
# the chain imposing a deadline. Measured 2026-08-10 (build-weekly 4901): Julia
# 1.12.6 deadlocked precompiling REPL, 50 minutes elapsed for 23 SECONDS of CPU.
#
# This image is the worse place for it to happen. At 394.9s this step is 67% of
# datascience-notebook, which at 587s is both the critical path and the tail of
# the jupyter stage -- it finishes roughly 5 minutes after every other image, so a
# hang here stalls the entire build with the machine otherwise idle.
#
# 1800s against a ~395s healthy run is ~4.5x headroom. --kill-after escalates to
# SIGKILL, because a deadlocked Julia does not necessarily service a TERM.
RUN timeout --kill-after=60 1800 /opt/setup-scripts/setup-julia-packages.bash \
    || { rc=$?; \
         echo "ERROR: julia package setup failed (rc=${rc}; 124/137 mean the \
1800s deadline was exceeded -- suspect a Pkg.precompile deadlock)" >&2; \
         exit "${rc}"; }

# R packages including IRKernel which gets installed globally.
# r-e1071: dependency of the caret R package
RUN mamba install --yes \
    'r-base' \
    'r-caret' \
    'r-crayon' \
    'r-devtools' \
    'r-e1071' \
    'r-forecast' \
    'r-hexbin' \
    'r-htmltools' \
    'r-htmlwidgets' \
    'r-irkernel' \
    'r-nycflights13' \
    'r-randomforest' \
    'r-rcurl' \
    'r-rmarkdown' \
    'r-rodbc' \
    'r-rsqlite' \
    'r-shiny' \
    'r-tidymodels' \
    'r-tidyverse' \
    'rpy2' \
    'unixodbc' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
