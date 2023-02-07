ARG FEDORA_MAJOR_VERSION=37

FROM ghcr.io/bsherman/silverblue-kmods:${FEDORA_MAJOR_VERSION}

COPY etc /etc

COPY ublue-firstboot /usr/bin

COPY --from=ghcr.io/ublue-os/udev-rules etc/udev/rules.d/* /etc/udev/rules.d

RUN rpm-ostree override remove firefox firefox-langpacks && \
    curl -sLO https://pkgs.tailscale.com/stable/fedora/tailscale.repo --output-dir /etc/yum.repos.d/ && \
    rpm-ostree install distrobox evolution gnome-shell-extension-appindicator gnome-shell-extension-dash-to-dock \
        gnome-shell-extension-gsconnect gnome-tweaks just libratbag-ratbagd libretls nautilus-gsconnect openssl \
        shotwell tailscale wireguard-tools && \
    sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl enable flatpak-automatic.timer && \
    systemctl enable rpm-ostree-countme.timer && \
    systemctl enable tailscaled && \
    ostree container commit
