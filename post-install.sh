#!/bin/sh

set -ouex pipefail

# add customized container policy based on upstream's
cat /usr/etc/containers/policy.json  | jq -M '.transports.docker += {"ghcr.io/bsherman":[{"type":"sigstoreSigned","keyPath":"/usr/etc/pki/containers/bsherman.pub","signedIdentity":{"type":"matchRepository"}}]}' > /tmp/bsherman-policy.json && \
  cp /tmp/bsherman-policy.json /usr/etc/containers/policy.json

# custom gnome overrides
mkdir -p /tmp/ublue-schema-test && \
find /usr/share/glib-2.0/schemas/ -type f ! -name "*.gschema.override" -exec cp {} /tmp/ublue-schema-test/ \; && \
cp /usr/share/glib-2.0/schemas/*-ublue-custom.gschema.override /tmp/ublue-schema-test/ && \
echo "Running error test for ublue-custom gschema override. Aborting if failed." && \
glib-compile-schemas --strict /tmp/ublue-schema-test || exit 1 && \
echo "Compiling gschema to include ublue-custom setting overrides" && \
glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null


# don't run docker by default
systemctl disable docker.service
systemctl disable docker.socket

# pre-enabled services
systemctl unmask dconf-update.service
systemctl enable dconf-update.service
systemctl enable rpm-ostree-countme.timer
systemctl enable tailscaled.service

# custom just recipes
sed -i "s/FEDORA_MAJOR_VERSION/${FEDORA_MAJOR_VERSION}/" /usr/share/ublue-os/just/60-custom.just

# custom shutdown timeouts
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf

# don't want these desktop icons
rm -f /usr/share/applications/{htop,nvtop}.desktop
