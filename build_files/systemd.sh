#!/usr/bin/bash

set -ouex pipefail

systemctl unmask dconf-update.service
systemctl enable dconf-update.service
systemctl enable rpm-ostree-countme.timer
systemctl enable libvirt-workaround.service
systemctl enable swtpm-workaround.service
systemctl enable tailscaled.service
#systemctl --global enable podman-auto-update.timer
