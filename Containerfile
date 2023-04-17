ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG IMAGE_SUFFIX="${IMAGE_SUFFIX:-main}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-37}"

FROM ghcr.io/ublue-os/${IMAGE_NAME}-${IMAGE_SUFFIX}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-37}"

COPY etc /etc
COPY usr /usr

# add akmods RPMs for installation
COPY --from="ghcr.io/bsherman/base-kmods:${FEDORA_MAJOR_VERSION}" /akmods            /tmp/akmods
COPY --from="ghcr.io/bsherman/base-kmods:${FEDORA_MAJOR_VERSION}" /akmods-custom-key /tmp/akmods-custom-key

ADD packages.json /tmp/packages.json
ADD akmods.sh /tmp/akmods.sh
ADD build.sh /tmp/build.sh
ADD github-release-install.sh /tmp/github-release-install.sh

RUN mkdir -p /var/lib/alternatives && \
    /tmp/akmods.sh && \
    /tmp/build.sh && \
    pip install --prefix=/usr yafti && \
    /tmp/github-release-install.sh twpayne/chezmoi chezmoi && \
    /tmp/github-release-install.sh LinusDierheimer/fastfetch fastfetch && \
    wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq && \
    wget https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz -O starship.tgz && \
    tar zxf starship.tgz && rm starship.tgz && chmod +x starship && mv starship /usr/bin/starship && \
    systemctl unmask dconf-update.service && \
    systemctl enable dconf-update.service && \
    systemctl enable rpm-ostree-countme.timer && \
    systemctl enable tailscaled && \
    rm -f /etc/yum.repos.d/tailscale.repo && \
    sed -i "s/FEDORA_MAJOR_VERSION/${FEDORA_MAJOR_VERSION}/" /etc/distrobox/distrobox.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    mv /var/lib/alternatives /staged-alternatives && \
    rm -rf /tmp/* /var/* && \
    ostree container commit && \
    mkdir -p /var/lib && mv /staged-alternatives /var/lib/alternatives && \
    mkdir -p /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp

# fleek for nix
COPY --from=docker.io/bketelsen/fleek:latest /app/fleek /usr/bin/fleek
COPY --from=docker.io/bketelsen/fleek:latest /en/man1/fleek.1.gz /usr/share/man/man1/fleek.1.gz
COPY --from=docker.io/bketelsen/fleek:latest /pt/man1/fleek.1.gz /usr/share/man/pt/man1/fleek.1.gz
COPY --from=docker.io/bketelsen/fleek:latest /completions/fleek.bash /etc/bash_completion.d/fleek
COPY --from=docker.io/bketelsen/fleek:latest /completions/fleek.zsh /usr/local/share/zsh/site-functions/_fleek

# k8s/container tools
COPY --from=cgr.dev/chainguard/cosign:latest /usr/bin/cosign /usr/bin/cosign
COPY --from=cgr.dev/chainguard/kubectl:latest /usr/bin/kubectl /usr/bin/kubectl
COPY --from=docker.io/docker/compose-bin:latest /docker-compose /usr/bin/docker-compose
