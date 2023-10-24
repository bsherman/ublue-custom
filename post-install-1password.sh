#!/usr/bin/env sh

set -ouex pipefail

echo "Fixing-up 1Password"

# On libostree systems, /opt is a symlink to /var/opt,
# which actually only exists on the live system. /var is
# a separate mutable, stateful FS that's overlaid onto
# the ostree rootfs. Therefore we need to install it into
# /usr/lib/1Password instead, and dynamically create a
# symbolic link /opt/1Password => /usr/lib/1Password upon
# boot.

## already done via install.sh
# Prepare staging directory
#mkdir -p /var/opt # -p just in case it exists

## already installed via packages.sh
#INSTALL_RPM='https://downloads.1password.com/linux/rpm/stable/x86_64/1password-latest.rpm'
#rpm-ostree install "${INSTALL_RPM}"

# Clean up the yum repo (updates are baked into new images)
rm /etc/yum.repos.d/1password.repo -f

# And then we do the hacky dance!
mv /var/opt/1Password /usr/lib/1Password # move this over here

# Create a symlink /usr/bin/1password => /opt/1Password/1password
rm /usr/bin/1password
ln -s /opt/1Password/1password /usr/bin/1password

#####
# The following is a bastardization of "after-install.sh"
# which is normally packaged with 1password. You can compare with
# /usr/lib/1Password/after-install.sh if you want to see.

cd /usr/lib/1Password

# chrome-sandbox requires the setuid bit to be specifically set.
# See https://github.com/electron/electron/issues/17972
chmod 4755 /usr/lib/1Password/chrome-sandbox

# Normally, after-install.sh would create a group,
# "onepassword", right about now. But if we do that during
# the ostree build it'll disappear from the running system!
# I'm going to work around that by hardcoding GIDs and
# crossing my fingers that nothing else steps on them.
# These numbers _should_ be okay under normal use, but
# if there's a more specific range that I should use here
# please submit a PR!

# Specifically, GID must be > 1000, and absolutely must not
# conflict with any real groups on the deployed system.
# Normal user group GIDs on Fedora are sequential starting
# at 1000, so let's skip ahead and set to something higher.
GID_ONEPASSWORD="1500"
GID_ONEPASSWORDCLI="1600"

HELPER_PATH="/usr/lib/1Password/1Password-KeyringHelper"
BROWSER_SUPPORT_PATH="/usr/lib/1Password/1Password-BrowserSupport"

# Setup the Core App Integration helper binaries with the correct permissions and group
chgrp "${GID_ONEPASSWORD}" "${HELPER_PATH}"
# The binary requires setuid so it may interact with the Kernel keyring facilities
chmod u+s "${HELPER_PATH}"
chmod g+s "${HELPER_PATH}"

# BrowserSupport binary needs setgid. This gives no extra permissions to the binary.
# It only hardens it against environmental tampering.
chgrp "${GID_ONEPASSWORD}" "${BROWSER_SUPPORT_PATH}"
chmod g+s "${BROWSER_SUPPORT_PATH}"

# Dynamically create the required group via sysusers.d
# and set the GID based on the files we just chgrp'd
cat >/usr/lib/sysusers.d/onepassword.conf <<EOF
g     onepassword ${HELPER_PATH}
EOF

# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
cat >/usr/lib/tmpfiles.d/onepassword.conf <<EOF
L  /opt/1Password  -  -  -  -  /usr/lib/1Password
EOF

## already installed via packages.sh
# Then we install the 1password CLI binary as well
#cd "$(mktemp -d)"
#wget -q https://cache.agilebits.com/dist/1P/op2/pkg/v2.14.0/op_linux_amd64_v2.14.0.zip
#unzip op_linux_amd64_v2.14.0.zip

#mv op /usr/bin

# it needs its own group and needs setgid, like the other helpers.
#groupadd -g ${GID_ONEPASSWORDCLI} onepassword-cli
chown root:${GID_ONEPASSWORDCLI} /usr/bin/op
chmod g+s /usr/bin/op

# Dynamically create the required group via sysusers.d
# and set the GID based on the files we just chgrp'd
cat >/usr/lib/sysusers.d/onepassword.conf <<EOF
g     onepassword-cli /usr/bin/op
EOF
