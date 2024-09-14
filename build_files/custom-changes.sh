#!/usr/bin/bash

set -ouex pipefail

# temporarily disabled for testing various signature verification methods
# add customized container policy based on upstream's
#cat /usr/etc/containers/policy.json  | jq -M '.transports.docker += {"ghcr.io/bsherman":[{"type":"sigstoreSigned","keyPath":"/usr/etc/pki/containers/bsherman.pub","signedIdentity":{"type":"matchRepository"}}]}' > /tmp/bsherman-policy.json && \
#  cp /tmp/bsherman-policy.json /usr/etc/containers/policy.json

if [[ "${BASE_IMAGE_NAME}" = "silverblue" ]]; then
  # custom gnome overrides
  mkdir -p /tmp/ublue-schema-test && \
  find /usr/share/glib-2.0/schemas/ -type f ! -name "*.gschema.override" -exec cp {} /tmp/ublue-schema-test/ \; && \
  cp /usr/share/glib-2.0/schemas/*-ublue-custom.gschema.override /tmp/ublue-schema-test/ && \
  echo "Running error test for ublue-custom gschema override. Aborting if failed." && \
  glib-compile-schemas --strict /tmp/ublue-schema-test || exit 1 && \
  echo "Compiling gschema to include ublue-custom setting overrides" && \
  glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null
fi

# custom shutdown timeouts
if [ ! -f /etc/systemd/user.conf ]; then
  cp /usr/lib/systemd/user.conf /etc/systemd/
fi
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf
