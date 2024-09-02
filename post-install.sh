#!/bin/sh

set -ouex pipefail

# temporarily disabled for testing various signature verification methods
# add customized container policy based on upstream's
#cat /usr/etc/containers/policy.json  | jq -M '.transports.docker += {"ghcr.io/bsherman":[{"type":"sigstoreSigned","keyPath":"/usr/etc/pki/containers/bsherman.pub","signedIdentity":{"type":"matchRepository"}}]}' > /tmp/bsherman-policy.json && \
#  cp /tmp/bsherman-policy.json /usr/etc/containers/policy.json

# custom gnome overrides
mkdir -p /tmp/ublue-schema-test && \
find /usr/share/glib-2.0/schemas/ -type f ! -name "*.gschema.override" -exec cp {} /tmp/ublue-schema-test/ \; && \
cp /usr/share/glib-2.0/schemas/*-ublue-custom.gschema.override /tmp/ublue-schema-test/ && \
echo "Running error test for ublue-custom gschema override. Aborting if failed." && \
glib-compile-schemas --strict /tmp/ublue-schema-test || exit 1 && \
echo "Compiling gschema to include ublue-custom setting overrides" && \
glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null


# pre-enabled services
systemctl unmask dconf-update.service
systemctl enable dconf-update.service
systemctl enable rpm-ostree-countme.timer
systemctl enable libvirt-workaround.service
systemctl enable swtpm-workaround.service
systemctl enable tailscaled.service

# custom just recipes
sed -i "s/FEDORA_MAJOR_VERSION/${FEDORA_MAJOR_VERSION}/" /usr/share/ublue-os/just/60-custom.just

# custom shutdown timeouts
if [ ! -f /etc/systemd/user.conf ]; then
  cp /usr/lib/systemd/user.conf /etc/systemd/
fi
if [ ! -f /etc/systemd/system.conf ]; then
  cp /usr/lib/systemd/system.conf /etc/systemd/
fi
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf

# generate pre-built initramfs only if main, since nvidia rebuilds this upstream
if [ "$FEDORA_MAJOR_VERSION" -ge "40" ]; then
  if [ "$IMAGE_SUFFIX" == "main" ]; then
    /tmp/build-initramfs.sh
  fi
fi

if [ "$FEDORA_MAJOR_VERSION" -ge "40" ]; then
  /usr/bin/bootupctl backend generate-update-metadata
fi
