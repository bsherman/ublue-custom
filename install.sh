#!/bin/sh

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# ensure that RPM post-install don't break with alternatives reqs
mkdir -p /var/lib/alternatives

# Get required repos
# tailscale
wget https://pkgs.tailscale.com/stable/fedora/tailscale.repo -O /etc/yum.repos.d/tailscale.repo
# ublue-staging: needed for tuned, nvk enabled mesa, etc
wget https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-${RELEASE}/ublue-os-staging-fedora-${RELEASE}.repo?arch=x86_64 -O /etc/yum.repos.d/_copr_ublue-os-staging.repo
if [ "sericea" == "${IMAGE_NAME}" ]; then
  wget https://copr.fedorainfracloud.org/coprs/tofik/sway/repo/fedora-${RELEASE}/tofik-sway-fedora-${RELEASE}.repo -O /etc/yum.repos.d/copr_tofik-sway.repo
fi

# use mesa from ublue-staging with nvk support until upstream supports it
rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
        mesa-vulkan-drivers

# install kmods if F39 or newer
if [ "${FEDORA_MAJOR_VERSION}" -ge 39 ]; then
  for REPO in $(rpm -ql ublue-os-akmods-addons|grep ^"/etc"|grep repo$); do
    echo "akmods: enable default entry: ${REPO}"
    sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' ${REPO}
  done
  rpm-ostree install /tmp/akmods-rpms/*.rpm
fi

# Prompt Terminal
if [ "silverblue" == "${IMAGE_NAME}" ]; then
  if [ ${FEDORA_MAJOR_VERSION} -ge "39" ]; then
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/prompt/repo/fedora-${RELEASE}/kylegospo-prompt-fedora-${RELEASE}.repo?arch=x86_64 -O /etc/yum.repos.d/_copr_kylegospo-prompt.repo && \
    rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:kylegospo:prompt \
        vte291 \
        vte-profile && \
    rpm-ostree install \
        prompt && \
    rm -f /etc/yum.repos.d/_copr_kylegospo-prompt.repo
  fi
fi

# run common packages script
/tmp/packages.sh

# disable installed repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
if [ "sericea" == "${IMAGE_NAME}" ]; then
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/copr_tofik-sway.repo
fi

### github direct installs
/tmp/github-release-install.sh twpayne/chezmoi x86_64
/tmp/github-release-install.sh wez/wezterm fedora${RELEASE}.x86_64

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
