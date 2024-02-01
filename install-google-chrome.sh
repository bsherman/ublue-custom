#!/usr/bin/env sh

# Thanks to bri for the inspiration! My script is based on this example:
# https://github.com/briorg/bluefin/blob/c62c30a04d42fd959ea770722c6b51216b4ec45b/scripts/1password.sh

set -ouex pipefail

echo "Installing Google Chrome"

# On libostree systems, /opt is a symlink to /var/opt,
# which actually only exists on the live system. /var is
# a separate mutable, stateful FS that's overlaid onto
# the ostree rootfs. Therefore we need to install it into
# /usr/lib/google instead, and dynamically create a
# symbolic link /opt/google => /usr/lib/google upon
# boot.

# Prepare staging directory
mkdir -p /var/opt # -p just in case it exists

# Prepare alternatives directory
mkdir -p /var/lib/alternatives

# Setup repo
cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-google
EOF

# Import signing key
curl --retry 3 --retry-delay 2 --retry-all-errors -sL \
  -o /etc/pki/rpm-gpg/RPM-GPG-KEY-google \
  https://dl.google.com/linux/linux_signing_key.pub
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-google

# Now let's install the packages.
rpm-ostree install google-chrome-stable

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
