#!/usr/bin/env sh

set -ouex pipefail

echo "Fixing-up Google Chrome"

# On libostree systems, /opt is a symlink to /var/opt,
# which actually only exists on the live system. /var is
# a separate mutable, stateful FS that's overlaid onto
# the ostree rootfs. Therefore we need to install it into
# /usr/lib/google instead, and dynamically create a
# symbolic link /opt/google => /usr/lib/google upon
# boot.

## already done via install.sh
# Prepare staging directory
#mkdir -p /var/opt # -p just in case it exists

## already installed via packages.sh
#INSTALL_RPM='https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm'
#rpm-ostree install "${INSTALL_RPM}"

# Clean up the yum repo (updates are baked into new images)
rm /etc/yum.repos.d/google-chrome.repo -f

# And then we do the hacky dance!
mv /var/opt/google /usr/lib/google # move this over here

#####
# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
cat >/usr/lib/tmpfiles.d/google.conf <<EOF
L  /opt/google  -  -  -  -  /usr/lib/google
EOF
