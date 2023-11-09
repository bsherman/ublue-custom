#!/bin/sh

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# ensure that RPM post-install don't break with alternatives reqs
mkdir -p /var/lib/alternatives

# Get required repos
wget https://pkgs.tailscale.com/stable/fedora/tailscale.repo -O /etc/yum.repos.d/tailscale.repo
if [ "sericea" == "${IMAGE_NAME}" ]; then
    wget https://copr.fedorainfracloud.org/coprs/tofik/sway/repo/fedora-${RELEASE}/tofik-sway-fedora-${RELEASE}.repo -O /etc/yum.repos.d/copr_tofik-sway.repo
fi

# install kmods if F39 or newer
if [[ "${FEDORA_MAJOR_VERSION}" -ge 39 ]]; then
  for REPO in $(rpm -ql ublue-os-akmods-addons|grep ^"/etc"|grep repo$); do
    echo "akmods: enable default entry: ${REPO}"
    sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' ${REPO}
  done
  rpm-ostree install /tmp/akmods-rpms/*.rpm
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
/tmp/github-release-install.sh wez/wezterm fedora38.x86_64

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

### gaming installs
if [[ "${FEDORA_MAJOR_VERSION}" -ge 39 ]]; then
  # first system76-scheduler
  wget https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/repo/fedora-$(rpm -E %fedora)/kylegospo-system76-scheduler-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo
  if [[ "${IMAGE_NAME}" == "silverblue" ]]; then
    rpm-ostree install gnome-shell-extension-system76-scheduler
  fi
  rpm-ostree install system76-scheduler
  systemctl enable com.system76.Scheduler.service
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo

  wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-multilib-fedora-$(rpm -E %fedora).repo?arch=x86_64 -O /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo

  rpm-ostree install \
      system76-scheduler \
      vulkan-tools \
      extest.i686 \
      vulkan-loader.i686 \
      alsa-lib.i686 \
      fontconfig.i686 \
      gtk2.i686 \
      libICE.i686 \
      libnsl.i686 \
      libxcrypt-compat.i686 \
      libpng12.i686 \
      libXext.i686 \
      libXinerama.i686 \
      libXtst.i686 \
      libXScrnSaver.i686 \
      NetworkManager-libnm.i686 \
      nss.i686 \
      pulseaudio-libs.i686 \
      libcurl.i686 \
      systemd-libs.i686 \
      libva.i686 \
      libvdpau.i686 \
      libdbusmenu-gtk3.i686 \
      libatomic.i686 \
      pipewire-alsa.i686 \
      clinfo

  sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/rpmfusion-nonfree-steam.repo
  sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/rpmfusion-nonfree.repo
  sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo
  sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/fedora-updates.repo
  rpm-ostree install steam
  if [[ "${IMAGE_NAME}" == "silverblue" ]]; then
      rpm-ostree override remove \
          gamemode \
          gnome-shell-extension-gamemode
  else
      rpm-ostree override remove \
          gamemode
  fi
  sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/rpmfusion-nonfree-steam.repo
  sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/rpmfusion-nonfree.repo
  sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo
  sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/fedora-updates.repo
  rpm-ostree install \
      wxGTK \
      libFAudio \
      gamescope.x86_64 \
      gamescope.i686 \
      wine-core.x86_64 \
      wine-core.i686 \
      wine-pulseaudio.x86_64 \
      wine-pulseaudio.i686 \
      winetricks \
      protontricks \
      vkBasalt.x86_64 \
      vkBasalt.i686 \
      mangohud.x86_64 \
      mangohud.i686 \
      gperftools-libs.i686
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo
fi
