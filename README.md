# ublue-custom

[![build-ublue](https://github.com/bsherman/ublue-custom/actions/workflows/build.yml/badge.svg)](https://github.com/bsherman/ublue-custom/actions/workflows/build.yml)

Custom Fedora immutable desktop images which are mostly stock, plus the few things that are needed to make life good on my family's laptops.

## What is this?

These images are customized how I want, based on the great work by [team ublue os](https://github.com/ublue-os).

Images built:
- Silverblue (Fedora GNOME immutable desktop)
- Kinoite (Fedora KDE immutable desktop)
- Sericea (Fedora Sway immutable desktop)

Based on:
- [ublue-os/main](https://github.com/ublue-os/main) for good foundations
  - adds distrobox, freeworld mesa and media codecs, gnome-tweaks (on gnome), just, nvtop, openssl, pipewire-codec-aptx, ratbagd, vim
  - sets automatic staging of updates to system
  - sets flatpaks to update twice a day
  - v4l2loopback driver from [ublue-os/akmods](https://github.com/ublue-os/akmods)
  - xpadneo/xone xbox controller drivers from [ublue-os/akmods](https://github.com/ublue-os/akmods)
- [ublue-os/nvida](https://github.com/ublue-os/nvidia) for nvidia variants adds:
  - nvidia kernel drivers
  - nvidia container runtime
  - nvidia vaapi driver
  - nvidia selinux config


## Features

In addition to the packages/config provided by base images, this image:
- Removes from the base image:
  - firefox
- Adds the following packages to the base image:
  - foot terminal for wayland
  - moby-engine (docker's open source version, disabled by default)
  - p7zip
  - ~~[pcp](https://pcp.io/) - Performance Co-pilot monitoring~~ *temporarily disabled until I sort out some issues*
  - powertop
  - shotwell (the flatpak version crashes accessing USB)
  - [tailscale](https://tailscale.com/) (for VPN)
  - tmux
  - [libvirtd/virsh](https://libvirt.org/) and [virt-manager](https://virt-manager.org/) (for installing/running VMs)
  - [wireguard-tools](https://www.wireguard.com/) (for more VPN)
  - Only on Silverblue: Gnome specific packages
    - default font set to Noto Sans
    - gnome shell extensions (appindicator, dash-to-dock, gsconnect, move-clock, no-overview, notifications-reloaded)
    - gsconnect (plus dependancies)
  - Only on Kinoite and Sericea
    - libadwaita(-qt)
    - zenity
  - Only on Sericea
    - some other packages for sway fun
- Sets faster timeout on systemd waiting for shutdown
- Sets gnome's "APP is not responding" check to 30 seconds
- Sets some a few custom gnome settings (see etc/dconf)

## Applications

- Flatpaks
    - This image does not actually change Fedora flatpak application defaults, but suggests changing them
        - Silverblue (Kinoite, Sericea, etc) by default, only come with the "fedora" flatpak remote pre-installed, and the Gnome apps which come on Silverblue are installed from that location
    - I suggest using the included `just setup-flatpak-repos` command to remove the `fedora` flatpak remote (and all apps from it) and setup the `flathub` remote (see below)
    - Then run `just install-apps-gnome` to install the now missing apps (plus a few nice extras)
    - Run `just` recipe with `-n` for a dry-run, eg: `just -n install-apps-creative`
- Lightly-tested scripts for easily enabling/disabling LUKS auto-unlock using TPM2.
  - `luks-enable-tpm2-autounlock` - backup `/etc/crypttab` and `systemd-cryptenroll`s TPM2 for unlock; requires existing LUKS2 password
  - `luks-disable-tpm2-autounlock` - restores the backup of `/etc/crypttab` and safely `systemd-cryptenroll` wipes TPM2 unlock slot

## Just Customizations

A `just` task runner default config is included for easy customization after first boot.
It will copy the template from `/etc/justfile` to your home directory.
After that run the following commands:

- `just` - Show all tasks, more will be added in the future
    - setup-flatpak-repos           # Setup flathub remote, remove fedora remote if present
    - bios                          # Boot into this device's BIOS/UEFI screen
    - changelogs                    # Show the changelog
    - clean-system                  # Clean up old containers and flatpaks
    - disable-updates               # Disable all auto-update timers
    - distrobox-arch                # Create an Arch container
    - distrobox-bazzite             # Create a Bazzite-Arch container
    - distrobox-boxkit              # Create an Alpine boxkit container
    - distrobox-debian              # Create a Debian container
    - distrobox-fedora              # Create a Fedora container
    - distrobox-fedora-custom       # Create a Fedora (bsherman custom) container
    - distrobox-opensuse            # Create an openSUSE container
    - distrobox-ubuntu              # Create an Ubuntu container
    - enable-updates                # Enable all auto-update timers
    - enroll-secure-boot-key        # Enroll Nvidia driver & KMOD signing key for secure boot - Enter password "ublue-os" if prompted
    - install-apps-creative         # Install Creative Media Apps
    - install-apps-gnome            # Install typical GNOME apps
    - install-apps-misc             # Install Other misc apps for my home users
    - install-apps-productivity     # Install Productivity and Communications apps
    - install-games-educational     # Install educational games
    - install-games-light           # Install light/casual games
    - install-games-linux           # Install Linux games
    - install-games-minecraft       # Install Minecraft games
    - install-games-steam           # Install Steam with MangoHud, Gamescope and Prototricks
    - install-pwa-flatpak-overrides # Give browsers permission to create PWAs (Progressive Web Apps)
    - install-virtualization        # Install virtualization stack (libvirt/virt-manager/etc)
    - nvidia-set-kargs              # Set needed kernel arguments for Nvidia GPUs
    - nvidia-setup-firefox-vaapi    # Enable VAAPI in Firefox Flatpak for Nvidia GPUs
    - nvidia-test-cuda              # Test CUDA support for Nvidia GPUs
    - regenerate-grub               # Regenerate GRUB config, useful in dual-boot scenarios where a second operating system isn't listed
    - uninstall-virtualization      # Un-install virtualization stack (libvirt/virt-manager/etc)
    - update                        # Update system, flatpaks, and containers all at once
    - update-firmware               # Update device firmware

Check the [just website](https://just.systems) for tips on modifying and adding your own recipes.


## Installation & Usage

### Install from Upstream

For the best experience, install from an official Fedora OSTree ISO:

- [Silverblue (GNOME)](https://fedoraproject.org/silverblue/download/)
- [Kinoite (KDE Plasma)](https://fedoraproject.org/kinoite/download/)
- [Sericea (Sway)](https://fedoraproject.org/sericea/download/)

### Rebase to Custom

After installation is complete, use the appropriate `rebase` command to install one of these custom images.

We build `latest` which currently points to Fedora 38 (Fedora 39 will become latest after it releases and related packages have stabilized). Fedora 37 is no longer built here. You can chose a specific version by using the `38` or `39` tag instead of `latest`:

    # pick any one of these
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-custom:latest
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-nvidia-custom:latest
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/kinoite-custom:latest
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/kinoite-nvidia-custom:latest
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/sericea-custom:latest
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/sericea-nvidia-custom:latest

We build date tags as well, so if you want to rebase to a particular day's release:
  
    # pick any one of these
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-custom:38-20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-nvidia-custom:38-20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/kinoite-custom:38-20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/kinoite-nvidia-custom:38-20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/sericea-custom:38-20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/sericea-nvidia-custom:38-20230302

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the appropriate command:

    cosign verify --key cosign.pub ghcr.io/bsherman/silverblue-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/silverblue-nvidia-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/kinoite-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/kinoite-nvidia-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/sericea-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/sericea-nvidia-custom
