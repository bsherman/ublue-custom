ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG IMAGE_SUFFIX="${IMAGE_SUFFIX:-main}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"

FROM ghcr.io/ublue-os/${SOURCE_IMAGE}-${IMAGE_SUFFIX}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG IMAGE_SUFFIX="${IMAGE_SUFFIX:-main}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"
ARG BROWSER_MODE="${BROWSER_MODE:-flatpak}"

# 0.12.1 matches docker/moby 24.0.5 which Fedora 40 has as of 2024-04-26
ARG DOCKER_BUILDX_VERSION=0.12.1
# 2.24.7 matches docker/moby 24.0.5 which Fedora 40 has as of 2024-04-26
ARG DOCKER_COMPOSE_VERSION=v2.24.7

COPY usr /usr

# add akmods RPMs for installation
#COPY --from="ghcr.io/bsherman/base-kmods:${FEDORA_MAJOR_VERSION}" /akmods            /tmp/akmods
#COPY --from="ghcr.io/bsherman/base-kmods:${FEDORA_MAJOR_VERSION}" /akmods-custom-key /tmp/akmods-custom-key
COPY --from=ghcr.io/ublue-os/akmods:main-${FEDORA_MAJOR_VERSION} /rpms/kmods/*xpad*.rpm /tmp/akmods-rpms/
COPY --from=ghcr.io/ublue-os/akmods:main-${FEDORA_MAJOR_VERSION} /rpms/kmods/*xone*.rpm /tmp/akmods-rpms/
COPY --from=ghcr.io/ublue-os/akmods:main-${FEDORA_MAJOR_VERSION} /rpms/kmods/*openrazer*.rpm /tmp/akmods-rpms/
COPY --from=ghcr.io/ublue-os/akmods:main-${FEDORA_MAJOR_VERSION} /rpms/kmods/*v4l2loopback*.rpm /tmp/akmods-rpms/

ADD packages.json /tmp/packages.json
ADD *.sh /tmp/

RUN rpm-ostree cliwrap install-to-root / && \
    /tmp/install.sh && \
    /tmp/post-install.sh && \
    rm -rf /tmp/* /var/* && \
    ostree container commit && \
    mkdir -p /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp

COPY --from=docker.io/docker/buildx-bin:${DOCKER_BUILDX_VERSION} /buildx /usr/libexec/docker/cli-plugins/docker-buildx
COPY --from=docker.io/docker/compose-bin:${DOCKER_COMPOSE_VERSION} /docker-compose /usr/libexec/docker/cli-plugins/docker-compose

RUN ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose && \
    ostree container commit && \
    mkdir -p /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp
