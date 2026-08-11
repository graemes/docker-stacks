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
#
# No base(N) clause: base(N) requires the referenced target to carry clone_all,
# which upstream satisfied via sandybridge. With sandybridge removed there is no
# valid base to reference -- base(1) fails "base index must refer to a previous
# target" and base(0) fails "base target must be clone_all". Verified against a
# real precompile; only the bare form builds.
ENV JULIA_CPU_TARGET="generic;haswell,-rdrnd"

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
# JULIA_NUM_PRECOMPILE_TASKS=1 serialises Pkg.precompile(). Build 4996 deadlocked
# here for the full 1800s on a REPL precompile worker at 1.6% CPU (three of the
# four julia precompiles in that run succeeded -- it is a race, not a hard break).
# Scoped to this RUN, not ENV, so images do not ship serial precompilation to
# users at runtime. This is a MITIGATION: the upstream hang is not root-caused.
RUN JULIA_NUM_PRECOMPILE_TASKS=1 \
    timeout --kill-after=60 1800 /opt/setup-scripts/setup-julia-packages.bash \
    || { rc=$?; \
         echo "ERROR: julia package setup failed (rc=${rc}; 124/137 mean the \
1800s deadline was exceeded -- suspect a Pkg.precompile deadlock)" >&2; \
         exit "${rc}"; }
