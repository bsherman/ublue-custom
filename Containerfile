ARG IMAGE_NAME="${IMAGE_NAME:-silverblue-kmods}"
ARG BASE_IMAGE="ghcr.io/bsherman/${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-37}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_NAME="${IMAGE_NAME:-silverblue-kmods}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-37}"

COPY etc /etc
COPY usr /usr

COPY --from=docker.io/bketelsen/fleek:latest /app/fleek /usr/bin/fleek
COPY --from=docker.io/bketelsen/fleek:latest /app/fleek.1.gz /usr/share/man/man1/fleek.1.gz

ADD packages.json /tmp/packages.json
ADD build.sh /tmp/build.sh

# this export IMAGE_NAME is a hack to make build.sh/packages.json work
# as the defaults expect. I should probably rework my workflow instead
RUN export IMAGE_NAME=$(echo "${IMAGE_NAME}" | cut -f1 -d-) && \
    mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    systemctl unmask dconf-update.service && \
    systemctl enable dconf-update.service && \
    systemctl enable rpm-ostree-countme.timer && \
    systemctl enable tailscaled && \
    rm -f /etc/yum.repos.d/tailscale.repo && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    mv /var/lib/alternatives /staged-alternatives && \
    rm -rf /tmp/* /var/* && \
    ostree container commit && \
    mkdir -p /var/lib && mv /staged-alternatives /var/lib/alternatives && \
    mkdir -p /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp
