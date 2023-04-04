ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG IMAGE_SUFFIX="${IMAGE_SUFFIX:-main}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-37}"

FROM ghcr.io/ublue-os/${IMAGE_NAME}-${IMAGE_SUFFIX}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-37}"

COPY etc /etc
COPY usr /usr

# fleek for nix
COPY --from=docker.io/bketelsen/fleek:latest /app/fleek /usr/bin/fleek
#COPY --from=docker.io/bketelsen/fleek:latest /app/man/man1/fleek.1.gz /usr/share/man/man1/fleek.1.gz
#COPY --from=docker.io/bketelsen/fleek:latest /app/man/pt/man1/fleek.1.gz /usr/share/man/pt/man1/fleek.1.gz

# k8s/container tools
COPY --from=cgr.dev/chainguard/cosign:latest /usr/bin/cosign /usr/bin/cosign
COPY --from=cgr.dev/chainguard/kubectl:latest /usr/bin/kubectl /usr/bin/kubectl
COPY --from=docker.io/docker/compose-bin:latest /docker-compose /usr/bin/docker-compose

# add in akmods
COPY --from="ghcr.io/bsherman/base-kmods:${FEDORA_MAJOR_VERSION}" /akmods            /tmp/akmods
COPY --from="ghcr.io/bsherman/base-kmods:${FEDORA_MAJOR_VERSION}" /akmods-custom-key /tmp/akmods-custom-key

ADD packages.json /tmp/packages.json
ADD akmods.sh /tmp/akmods.sh
ADD build.sh /tmp/build.sh
ADD github-release-install.sh /tmp/github-release-install.sh

RUN mkdir -p /var/lib/alternatives && \
    /tmp/akmods.sh && \
    /tmp/build.sh && \
    /tmp/github-release-install.sh wez/wezterm wezterm fedora37 && \
    /tmp/github-release-install.sh LinusDierheimer/fastfetch fastfetch && \
    systemctl unmask dconf-update.service && \
    systemctl enable dconf-update.service && \
    systemctl enable rpm-ostree-countme.timer && \
    systemctl enable tailscaled && \
    rm -f /etc/yum.repos.d/{tailscale,terra}.repo && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    mv /var/lib/alternatives /staged-alternatives && \
    rm -rf /tmp/* /var/* && \
    ostree container commit && \
    mkdir -p /var/lib && mv /staged-alternatives /var/lib/alternatives && \
    mkdir -p /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp
