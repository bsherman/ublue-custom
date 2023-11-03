ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG IMAGE_SUFFIX="${IMAGE_SUFFIX:-main}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

#FROM ghcr.io/ublue-os/${IMAGE_NAME}-${IMAGE_SUFFIX}:${FEDORA_MAJOR_VERSION}
FROM quay.io/fedora-ostree-desktops/${IMAGE_NAME}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"
ARG BROWSER_MODE="${BROWSER_MODE:-flatpak}"

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

RUN /tmp/install.sh && \
    /tmp/post-install.sh && \
    rm -rf /tmp/* /var/* && \
    ostree container commit && \
    mkdir -p /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp

COPY --from=docker.io/docker/compose-bin:latest /docker-compose /usr/bin/docker-compose
