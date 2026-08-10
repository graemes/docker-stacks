# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_IMAGE=$REGISTRY/$OWNER/minimal-notebook
FROM $BASE_IMAGE

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Julia dependencies
# install Julia packages in /opt/julia instead of ${HOME}
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
# Wrapped in `timeout`. setup-julia-packages.bash runs Pkg.update() and
# Pkg.precompile() unpinned on every --no-cache build, so any upstream Julia or
# package release can hang it indefinitely, and nothing else in the chain has a
# deadline -- not the script, not build-container.sh, not build-weekly.
#
# Measured 2026-08-10 (build-weekly 4901): Julia 1.12.6 deadlocked precompiling
# REPL for 50 minutes having consumed 23 SECONDS of CPU. Sleeping, no network, no
# disk. Every other image had finished; this one alone would have held the run
# until the 6h AWX timeout. A healthy run of this step takes ~8m20s, so 1800s is
# roughly 3.5x headroom and only fires on a genuine hang.
#
# --kill-after escalates to SIGKILL a minute after SIGTERM: a deadlocked Julia
# will not necessarily service a TERM, and a timeout that cannot actually
# terminate is not a timeout. rc 124 is timeout's "deadline exceeded", 137 is the
# KILL escalation -- reported explicitly so this is not misread as a genuine
# package build failure.
RUN timeout --kill-after=60 1800 /opt/setup-scripts/setup-julia-packages.bash \
    || { rc=$?; \
         echo "ERROR: julia package setup failed (rc=${rc}; 124/137 mean the \
1800s deadline was exceeded -- suspect a Pkg.precompile deadlock)" >&2; \
         exit "${rc}"; }
