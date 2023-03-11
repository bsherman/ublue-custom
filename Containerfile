ARG IMAGE_NAME="${IMAGE_NAME:-silverblue-kmods}"
ARG BASE_IMAGE="ghcr.io/bsherman/${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-37}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}

COPY etc /etc

COPY luks-*-tpm2-autounlock /usr/bin
COPY ublue-firstboot /usr/bin

ARG IMAGE_NAME="${IMAGE_NAME:-silverblue-kmods}"

RUN if [[ "${IMAGE_NAME}" == "silverblue"* ]]; then \
        DE_PKGS="\
gnome-shell-extension-appindicator \
gnome-shell-extension-dash-to-dock \
gnome-shell-extension-gsconnect \
nautilus-gsconnect"; \
    else DE_PKGS="zenity"; \
    fi; \
    rpm-ostree override remove firefox firefox-langpacks && \
    mkdir -p /var/lib/alternatives && \
    rpm-ostree install --idempotent \
        ${DE_PKGS} \
        evolution \
        inotify-tools \
        libratbag-ratbagd \
        libretls \
        powertop \
        shotwell \
        tailscale \
        virt-manager \
        wireguard-tools && \
    rm -f /var/lib/unbound/root.key && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=30s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=30s/' /etc/systemd/system.conf && \
    systemctl unmask dconf-update.service && \
    systemctl enable dconf-update.service && \
    systemctl enable rpm-ostree-countme.timer && \
    systemctl enable tailscaled && \
    mv /var/lib/alternatives /staged-alternatives && \
    ostree container commit && \
    mkdir -p /var/lib && mv /staged-alternatives /var/lib/alternatives && \
    mkdir -p /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp
