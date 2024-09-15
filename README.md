# ublue-custom

[![build-ublue](https://github.com/bsherman/ublue-custom/actions/workflows/build.yml/badge.svg)](https://github.com/bsherman/ublue-custom/actions/workflows/build.yml)

Custom Fedora immutable desktop images which are mostly stock, plus the few things that are needed to make life good on my family's laptops.

## What is this?

These images are customized how I want, based on the great work by [team ublue os](https://github.com/ublue-os).

Images built:
- Silverblue (Fedora GNOME immutable desktop)
- Kinoite (Fedora KDE immutable desktop)

Based on:
- [ublue-os/main](https://github.com/ublue-os/main) for good foundations
  - adds distrobox, freeworld mesa and media codecs, gnome-tweaks (on gnome), just, nvtop, openssl, pipewire-codec-aptx, ratbagd, vim
  - sets automatic staging of updates to system
  - sets flatpaks to update twice a day
- [ublue-os/nvida](https://github.com/ublue-os/nvidia) for nvidia variants adds:
  - nvidia kernel drivers
  - nvidia container runtime
  - nvidia vaapi driver
  - nvidia selinux config


## Features

In addition to the packages/config provided by ublue-os main images, this:
- Removes from the base image:
  - firefox
  - gnome-extensions-app (replaced with Gnome Extensions flatpak)
  - gnome-
- Adds the following packages to the base image:
  - akmods from[ublue-os/akmods](https://github.com/ublue-os/akmods)
    - openrazer driver
    - v4l2loopback driver
    - xbox controller drivers (xpadneo/xone)
  - [docker-ce](https://docs.docker.com/engine/install/fedora/) docker's community edition, disabled by default
  - [p7zip](https://github.com/p7zip-project/p7zip)
  - ~~[pcp](https://pcp.io/) - Performance Co-pilot monitoring~~ *temporarily disabled until I sort out some issues*
  - [ptyxis](https://gitlab.gnome.org/chergert/ptyxis) (pronounced *tik-sys*) is a container oriented terminal
  - [powertop](https://github.com/fenrus75/powertop)
  - [tailscale](https://tailscale.com/) for VPN
  - [libvirtd](https://libvirt.org/) and [qemu](https://qemu.org/) backend for running [kvm](https://linux-kvm.org/) VMs
  - [virt-manager](https://virt-manager.org/) UI for managing VMs on libvirtd
  - [waydroid](https://waydro.id/)
  - [wireguard-tools](https://www.wireguard.com/) for more VPN
  - zenity - for UI scripting
  - Only on Silverblue: Gnome specific packages
    - default font set to Inter and monospace font to IBM Plex Mono
    - gnome shell extensions (appindicator, caffeine, dash-to-dock, gsconnect, no-overview, search-light, tailscale-gnome-qs )
    - gsconnect (plus dependancies)
  - Only on Kinoite: KDE specific packages
    - k3b
    - libadwaita(-qt)
    - skanpage
- Sets faster timeout on systemd waiting for user processes to shutdown
- Sets gnome's "APP is not responding" check to 30 seconds
- Sets some custom gnome default settings (see etc/dconf)

## Applications

- Flatpaks
    - This image does not actually change Fedora flatpak application defaults, but suggests changing them
        - Silverblue (Kinoite, etc) by default, only come with the "fedora" flatpak remote pre-installed, and the Gnome apps which come on Silverblue are installed from that location
    - I suggest using the included `just setup-flatpak-repos` command to remove the `fedora` flatpak remote (and all apps from it) and setup the `flathub` remote (see below)
    - Then run `just install-apps-gnome` to install the now missing apps (plus a few nice extras)
    - Run `just` recipe with `-n` for a dry-run, eg: `just -n install-apps-creative`
- Lightly-tested scripts for easily enabling/disabling LUKS auto-unlock using TPM2.
  - `luks-enable-tpm2-autounlock` - backup `/etc/crypttab` and `systemd-cryptenroll`s TPM2 for unlock; requires existing LUKS2 password
  - `luks-disable-tpm2-autounlock` - restores the backup of `/etc/crypttab` and safely `systemd-cryptenroll` wipes TPM2 unlock slot

## Just Customizations

A `just` task runner default config is included for easy customization after first boot.
It will copy a template to your home directory.

After that run `ujust` to get a list of default commands ( a sample set of commands is included below ):

```bash
`ujust
Click here to view the Universal Blue just documentation
Available commands:
 - bios                           # Boot into this device's BIOS/UEFI screen
 - changelogs                     # Show the changelog
 - configure-nvidia ACTION="prompt" # Configure the Nvidia driver
 - distrobox-fedora-custom        # Create a Fedora (bsherman custom) container
 - enroll-secure-boot-key         # Enroll Nvidia driver & KMOD signing key for secure boot - Enter password "ublue-os" if prompted
 - install-apps-creative          # Install Creative Media Apps
 - install-apps-gnome             # Install typical GNOME apps
 - install-apps-misc              # Install Other misc apps for my home users
 - install-apps-productivity      # Install Productivity and Communications apps
 - install-games-educational      # Install educational games
 - install-games-light            # Install light/casual games
 - install-games-linux            # Install Linux games
 - install-games-minecraft        # Install Minecraft games
 - install-games-steam            # Install Steam with MangoHud, Gamescope and Prototricks
 - install-obs-studio-portable    # Install obs-studio-portable from wimpysworld, which bundles an extensive collection of 3rd party plugins
 - install-pwa-flatpak-overrides  # Give browsers permission to create PWAs (Progressive Web Apps)
 - logs-last-boot                 # Show all messages from last boot
 - logs-this-boot                 # Show all messages from this boot
 - toggle-updates ACTION="prompt" # Turn automatic updates on or off
 - auto-update ACTION="prompt"    # alias for `toggle-updates`
 - toggle-user-motd               # Toggle display of the user-motd in terminal
 - update VERB_LEVEL="full"       # Update system, flatpaks, and containers all at once
 - upgrade VERB_LEVEL="full"      # alias for `update`
 - update-firmware                # Update device firmware
```

Check the [just website](https://just.systems) for tips on modifying and adding your own recipes.


## Installation & Usage

### Install from Upstream

For the best experience, install from an official Fedora OSTree ISO:

- [Silverblue (GNOME)](https://fedoraproject.org/silverblue/download/)
- [Kinoite (KDE Plasma)](https://fedoraproject.org/kinoite/download/)

### Rebase to Custom

After installation is complete, use the appropriate `rebase` command to install one of these custom images.

**For `IMAGE_NAME` in the commands below, substitute one of these image names:**

- `silverblue-custom`
- `silverblue-nvidia-custom`
- `kinoite-custom`
- `kinoite-nvidia-custom`

**For `TAG` in the commands below, substitute one of these tags:**

- `latest` - Fedora 40 with the current released kernnel
    - this currently points to Fedora 40, and will update after upstreams have released and the current image is tested satisfactorily
- `stable` - Fedora 40 with the last Fedora CoreOS stable kernel
    - this delays kernel upgrades a bit to avoid kernel regressions

We build date tags as well, so for particular day's image, there are:

- `FR-YYYYMMDD`, eg `40-20240913` - latest is referenced by Fedora release number (FR) and date
- `stable-YYYYMMDD` , eg `stable-20240914` - stable is referenced by stable and date


```bash
sudo rpm-ostree rebase \
    ostree-unverified-registry:ghcr.io/bsherman/IMAGE_NAME:TAG
```

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/) using both OpenID Connect with Github and a repo specific keypair. You can verify the signature by running one the following command:

    cosign verify \
        --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
        --certificate-identity-regexp "https://github.com/bsherman/ublue-custom" \
        ghcr.io/bsherman/IMAGE_NAME:TAG

    cosign verify --key cosign.pub ghcr.io/bsherman/IMAGE_NAME:TAG

