#!/bin/sh

set -ouex pipefail

/tmp/post-install-1password.sh
/tmp/post-install-google-chrome.sh

systemctl disable docker.service
systemctl disable docker.socket

systemctl unmask dconf-update.service
systemctl enable dconf-update.service

systemctl enable rpm-ostree-countme.timer
systemctl enable tailscaled.service

sed -i "s/FEDORA_MAJOR_VERSION/${FEDORA_MAJOR_VERSION}/" /usr/share/ublue-os/just/60-custom.just
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf

rm -f /usr/share/applications/{htop,nvtop}.desktop
