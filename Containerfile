ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG AKMODS_FLAVOR="${AKMODS_FLAVOR:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-${BASE_IMAGE_NAME}-${IMAGE_FLAVOR}}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"
ARG NVIDIA_TYPE="${NVIDIA_TYPE:-}"
ARG KERNEL="${KERNEL:-6.10.7-200.fc40.x86_64}"

# FROM's for Mounting
ARG KMOD_SOURCE_COMMON="ghcr.io/ublue-os/akmods:${AKMODS_FLAVOR}-${FEDORA_MAJOR_VERSION}"
ARG ZFS_CACHE="ghcr.io/ublue-os/akmods-zfs:coreos-stable-${FEDORA_MAJOR_VERSION}"
ARG NVIDIA_CACHE="ghcr.io/ublue-os/akmods-nvidia:${AKMODS_FLAVOR}-${FEDORA_MAJOR_VERSION}"
ARG KERNEL_CACHE="ghcr.io/ublue-os/${AKMODS_FLAVOR}-kernel:${KERNEL}"
FROM ${KMOD_SOURCE_COMMON} AS akmods
FROM ${ZFS_CACHE} AS zfs_cache
FROM ${NVIDIA_CACHE} AS nvidia_cache
FROM ${KERNEL_CACHE} AS kernel_cache

FROM scratch AS ctx
COPY / /

# base image section
FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS base

ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG AKMODS_FLAVOR="${AKMODS_FLAVOR:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"
ARG NVIDIA_TYPE="${NVIDIA_TYPE:-}"
ARG IMAGE_NAME="${IMAGE_NAME:-silverblue-custom}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-bsherman}"
ARG UBLUE_IMAGE_TAG="${UBLUE_IMAGE_TAG:-latest}"

# Build, cleanup, commit.
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=akmods,source=/rpms,target=/tmp/akmods \
    --mount=type=bind,from=nvidia_cache,source=/rpms,target=/tmp/akmods-rpms \
    --mount=type=bind,from=kernel_cache,source=/tmp/rpms,target=/tmp/kernel-rpms \
    --mount=type=bind,from=zfs_cache,source=/rpms,target=/tmp/akmods-zfs \
    rpm-ostree cliwrap install-to-root / && \
    mkdir -p /var/lib/alternatives && \
    /ctx/build_files/build-base.sh  && \
    mv /var/lib/alternatives /staged-alternatives && \
    /ctx/build_files/clean-stage.sh && \
    ostree container commit && \
    mkdir -p /var/lib && mv /staged-alternatives /var/lib/alternatives && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp
