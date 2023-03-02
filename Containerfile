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
gnome-tweaks \
nautilus-gsconnect"; \
    else DE_PKGS="zenity"; \
    fi; \
    rpm-ostree override remove firefox firefox-langpacks && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/repo/fedora-37/kylegospo-webapp-manager-fedora-37.repo -O /etc/yum.repos.d/kylegospo-webapp-manager-fedora-37.repo && \
    rpm-ostree install ${DE_PKGS} \
        distrobox \
        evolution \
        inotify-tools \
        just \
        libratbag-ratbagd \
        libretls \
        openssl \
        powertop \
        shotwell \
        tailscale \
        virt-manager \
        webapp-manager \
        wireguard-tools && \
    rm -f /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
    rm -f /var/lib/freeipmi/ipckey && \
    rm -f /var/lib/unbound/root.key && \
    sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=30s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=30s/' /etc/systemd/system.conf && \
    systemctl unmask dconf-update.service && \
    systemctl enable dconf-update.service && \
    systemctl enable flatpak-automatic.timer && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl enable rpm-ostree-countme.timer && \
    systemctl enable tailscaled && \
    ostree container commit
