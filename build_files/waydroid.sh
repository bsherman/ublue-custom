#!/usr/bin/env sh

# installs waydroid using bazzite's packages and modifications
# but without depending on the bazzite images.

set -ouex pipefail

echo "Installing Waydroid"

curl -Lo /etc/yum.repos.d/_copr_kylegospo-bazzite.repo https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-bazzite-fedora-"${FEDORA_MAJOR_VERSION}".repo

rpm-ostree install waydroid cage wlr-randr

rm -f /etc/yum.repos.d/_copr_kylegospo-bazzite.repo

sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh

systemctl enable waydroid-workaround.service
systemctl disable waydroid-container.service
curl -Lo /usr/bin/waydroid-choose-gpu https://raw.githubusercontent.com/KyleGospo/waydroid-scripts/main/waydroid-choose-gpu.sh
chmod +x /usr/bin/waydroid-choose-gpu

sed -i 's@Exec=waydroid first-launch@Exec=/usr/bin/waydroid-launcher first-launch@g' /usr/share/applications/Waydroid.desktop
