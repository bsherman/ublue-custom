#!/bin/sh

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# ensure that RPM post-install don't break with alternatives reqs
mkdir -p /var/lib/alternatives

# Get required repos
wget https://pkgs.tailscale.com/stable/fedora/tailscale.repo -O /etc/yum.repos.d/tailscale.repo
wget https://copr.fedorainfracloud.org/coprs/rhcontainerbot/bootc/repo/fedora-${RELEASE}/bootc-${RELEASE}.repo -O /etc/yum.repos.d/copr_bootc.repo

if [ "sericea" == "${IMAGE_NAME}" ]; then
    wget https://copr.fedorainfracloud.org/coprs/tofik/sway/repo/fedora-${RELEASE}/tofik-sway-fedora-${RELEASE}.repo -O /etc/yum.repos.d/copr_tofik-sway.repo
fi

# run common packages script
/tmp/packages.sh

# disable installed repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/{copr*,tailscale}.repo

### github direct installs
/tmp/github-release-install.sh twpayne/chezmoi x86_64

### custom installs
/tmp/install-1password.sh
/tmp/install-brave-browser.sh
/tmp/install-google-chrome.sh
