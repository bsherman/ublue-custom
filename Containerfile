ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG IMAGE_SUFFIX="${IMAGE_SUFFIX:-main}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

FROM ghcr.io/ublue-os/${SOURCE_IMAGE}-${IMAGE_SUFFIX}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG IMAGE_SUFFIX="${IMAGE_SUFFIX:-main}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"
ARG BROWSER_MODE="${BROWSER_MODE:-flatpak}"

COPY system_files/ /

# add akmods RPMs for installation
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
