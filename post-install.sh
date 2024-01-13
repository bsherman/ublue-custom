#!/bin/sh

set -ouex pipefail

# add customized container policy based on upstream's
cat /usr/etc/containers/policy.json  | jq -M '.transports.docker += {"ghcr.io/bsherman":[{"type":"sigstoreSigned","keyPath":"/usr/etc/pki/containers/bsherman.pub","signedIdentity":{"type":"matchRepository"}}]}' > /tmp/bsherman-policy.json && \
  cp /tmp/bsherman-policy.json /usr/etc/containers/policy.json

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
