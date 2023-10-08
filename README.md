# ublue-custom

[![build-ublue](https://github.com/bsherman/ublue-custom/actions/workflows/build.yml/badge.svg)](https://github.com/bsherman/ublue-custom/actions/workflows/build.yml)

Custom Fedora immutable desktop images which are mostly stock, plus the few things that are needed to make life good on my family's laptops.

## What is this?

These images are customized how I want, based on the great work by [team ublue os](https://github.com/ublue-os).

Images built:
- Silverblue (Fedora GNOME immutable desktop)
- Kinoite (Fedora KDE immutable desktop)
- Sericea (Fedora Sway immutable desktop)
*I no longer build Vauxite (XFCE) as the 3 above are official Fedora immutable desktop editions.*

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

#### NOTE: this project is not formally affiliated with [ublue-os](https://github.com/ublue-os/) and is not supported by their team.

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

- Unlike the [ublue base image](https://github.com/ublue-os/base), flatpak applications are installed system wide, but are they are still not on the base image, as they install to /var.
- Also unlike the [ublue base image](https://github.com/ublue-os/base), the yafti "first run script" only executes for the default user which first logs into the system. We still use that process to customize flatpak refs and install default apps, but it only needs to run once as we install those apps to system.
- Several applications are available for (optional) install via yafti: [list of applications](https://github.com/bsherman/ublue-custom/blob/main/etc/yafti.yml#L24C5-L101)
- Lightly-tested scripts for easily enabling/disabling LUKS auto-unlock using TPM2.
  - `luks-enable-tpm2-autounlock` - backup `/etc/crypttab` and `systemd-cryptenroll`s TPM2 for unlock; requires existing LUKS2 password
  - `luks-disable-tpm2-autounlock` - restores the backup of `/etc/crypttab` and safely `systemd-cryptenroll` wipes TPM2 unlock slot

## Further Customization

A `just` task runner default config is included for further customization after first boot.
It will copy the template from `/etc/justfile` to your home directory.
After that run the following commands:

- `just` - Show all tasks, more will be added in the future
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
    - install-apps-common           # Install common apps for my home users
    - install-apps-creative         # Install Creative Media Apps
    - install-apps-misc             # Install Other misc apps for my home users
    - install-games-educational     # Install educational games
    - install-games-light           # Install light/casual games
    - install-games-linux           # Install Linux games
    - install-games-minecraft       # Install Minecraft games
    - install-obs-studio-portable   # Install obs-studio-portable from wimpysworld, which bundles an extensive collection of 3rd party plugins
    - install-pwa-flatpak-overrides # Give browsers permission to create PWAs (Progressive Web Apps)
    - install-steam                 # Install Steam with MangoHud, Gamescope and Prototricks
    - install-virtualization        # Install virtualization stack (libvirt/virt-manager/etc)
    - nvidia-set-kargs              # Set needed kernel arguments for Nvidia GPUs
    - nvidia-setup-firefox-vaapi    # Enable VAAPI in Firefox Flatpak for Nvidia GPUs
    - nvidia-test-cuda              # Test CUDA support for Nvidia GPUs
    - regenerate-grub               # Regenerate GRUB config, useful in dual-boot scenarios where a second operating system isn't listed
    - uninstall-virtualization      # Un-install virtualization stack (libvirt/virt-manager/etc)
    - update                        # Update system, flatpaks, and containers all at once
    - update-firmware               # Update device firmware

Check the [just website](https://just.systems) for tips on modifying and adding your own recipes.


## Usage

We build `latest` which now points to Fedora 38 as it has stabilized. But Fedora 37 builds are still available. You can chose a specific version by using the `37` or `38` tag:

    # pick any one of these
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-custom:latest
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-nvidia-custom:latest
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/kinoite-custom:latest
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/kinoite-nvidia-custom:latest
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/sericea-custom:latest
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/sericea-nvidia-custom:latest

We build date tags as well, so if you want to rebase to a particular day's release:
  
    # pick any one of these
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-custom:20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-nvidia-custom:20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/kinoite-custom:20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/kinoite-nvidia-custom:20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/sericea-custom:20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/sericea-nvidia-custom:20230302

The `latest` tag will automatically point to the latest stable build, but I suggest using version 37, 38, etc as they become available to avoid surprise upgrades.

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the appropriate command:

    cosign verify --key cosign.pub ghcr.io/bsherman/silverblue-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/silverblue-nvidia-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/kinoite-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/kinoite-nvidia-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/sericea-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/sericea-nvidia-custom
