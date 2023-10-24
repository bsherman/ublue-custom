#!/bin/sh

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# ensure that RPM post-install don't break with alternatives reqs
mkdir -p /var/lib/alternatives
# ensure that 1password/google-chrome can install
mkdir -p /var/opt

# Get required repos
wget https://pkgs.tailscale.com/stable/fedora/tailscale.repo -O /etc/yum.repos.d/tailscale.repo
wget https://copr.fedorainfracloud.org/coprs/rhcontainerbot/bootc/repo/fedora-${RELEASE}/bootc-${RELEASE}.repo -O /etc/yum.repos.d/copr_bootc.repo

cat << EOF > /etc/yum.repos.d/1password.repo
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF
cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF

# Import signing keys
rpm --import https://downloads.1password.com/linux/keys/1password.asc
rpm --import https://dl.google.com/linux/linux_signing_key.pub

if [ "sericea" == "${IMAGE_NAME}" ]; then
    wget https://copr.fedorainfracloud.org/coprs/tofik/sway/repo/fedora-${RELEASE}/tofik-sway-fedora-${RELEASE}.repo -O /etc/yum.repos.d/copr_tofik-sway.repo
fi

# run common packages script
/tmp/packages.sh

# disable installed repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/{copr*,tailscale}.repo

### github direct installs
/tmp/github-release-install.sh twpayne/chezmoi x86_64
