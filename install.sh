#!/bin/sh

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# ensure that RPM post-install don't break with alternatives reqs
mkdir -p /var/lib/alternatives

# Get required repos
# tailscale
curl https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo
# ublue-staging: needed for tuned, nvk enabled mesa, etc
curl https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-${RELEASE}/ublue-os-staging-fedora-${RELEASE}.repo?arch=x86_64 -o /etc/yum.repos.d/_copr_ublue-os-staging.repo
if [ "sericea" == "${IMAGE_NAME}" ]; then
  curl https://copr.fedorainfracloud.org/coprs/tofik/sway/repo/fedora-${RELEASE}/tofik-sway-fedora-${RELEASE}.repo -o /etc/yum.repos.d/copr_tofik-sway.repo
fi

for REPO in $(rpm -ql ublue-os-akmods-addons|grep ^"/etc"|grep repo$); do
  echo "akmods: enable default entry: ${REPO}"
  sed -i.bak '0,/enabled=0/{s/enabled=0/enabled=1/}' ${REPO}
done
rpm-ostree install /tmp/akmods-rpms/*.rpm
for REPO in $(rpm -ql ublue-os-akmods-addons|grep ^"/etc"|grep repo$); do
  echo "akmods: restore defaults: ${REPO}"
  mv ${REPO}.bak ${REPO}
done

# Ptyxis Terminal
if [ "${FEDORA_MAJOR_VERSION}" -ge "40" ]; then
  # F40 installs ptyxis with mutter patch
  rpm-ostree override replace \
  --experimental \
  --from repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
      vte291 \
      vte-profile
  rpm-ostree install ptyxis
else
  # F39 needs libadwaita for ptyxis too, and not patching mutter
  rpm-ostree override replace \
  --experimental \
  --from repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
      gtk4 \
      vte291 \
      vte-profile \
      libadwaita && \
  rpm-ostree install \
      ptyxis
fi


# run common packages script
/tmp/packages.sh

# remove used repos
rm -f /etc/yum.repos.d/_copr_kylegospo*
rm -f /etc/yum.repos.d/tailscale.repo
if [ "sericea" == "${IMAGE_NAME}" ]; then
  rm -f /etc/yum.repos.d/copr_tofik-sway.repo
fi

### github direct installs
/tmp/github-release-install.sh twpayne/chezmoi x86_64

### browser installs
if [ "hostrpm" == "${BROWSER_MODE}" ]; then
  # use host-native browser installation
  /tmp/install-1password.sh
  /tmp/install-brave-browser.sh
  /tmp/install-google-chrome.sh
else
  # for flatpak/distrbox only browser installation
  rpm-ostree override remove firefox firefox-langpacks
fi
