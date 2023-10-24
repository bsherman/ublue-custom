ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG IMAGE_SUFFIX="${IMAGE_SUFFIX:-main}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

FROM ghcr.io/ublue-os/${IMAGE_NAME}-${IMAGE_SUFFIX}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

COPY usr /usr

# add akmods RPMs for installation
#COPY --from="ghcr.io/bsherman/base-kmods:${FEDORA_MAJOR_VERSION}" /akmods            /tmp/akmods
#COPY --from="ghcr.io/bsherman/base-kmods:${FEDORA_MAJOR_VERSION}" /akmods-custom-key /tmp/akmods-custom-key

ADD packages.json /tmp/packages.json
ADD *.sh /tmp/

RUN /tmp/install.sh && \
    /tmp/post-install.sh && \
    rm -rf /tmp/* /var/* && \
    ostree container commit && \
    mkdir -p /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp

COPY --from=docker.io/docker/compose-bin:latest /docker-compose /usr/bin/docker-compose
