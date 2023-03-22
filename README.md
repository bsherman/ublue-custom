# ublue-custom

[![build-ublue](https://github.com/bsherman/ublue-custom/actions/workflows/build.yml/badge.svg)](https://github.com/bsherman/ublue-custom/actions/workflows/build.yml)

Custom Fedora immutable desktop images which are mostly stock, plus the few things that are needed to make life good on my family's laptops.

## What is this?

These images are customized how I want, based on the great work by [team ublue os](https://github.com/ublue-os).

Based on:
- [ublue-os/main](https://github.com/ublue-os/main) for good foundations
  - adds distrobox, freeworld mesa and media codecs, gnome-tweaks (on gnome), just, nvtop, openssl, pipewire-codec-aptx, vim
  - sets automatic staging of updates to system
  - sets flatpaks to update twice a day
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
  - evolution (needed to easily add CalDAV/CardDAV sources for Geary/Calendar)
  - inotify-tools
  - powertop
  - ratbagd (for Piper mouse management)
  - shotwell (the flatpak version crashes accessing USB)
  - [tailscale](https://tailscale.com/) (for VPN)
  - [libvirtd/virsh](https://libvirt.org/) and [virt-install](https://virt-manager.org/) (for installing/running VMs)
  - [wireguard-tools](https://www.wireguard.com/) (for more VPN)
  - xpadneo/xone xbox controller drivers from [ublue-kmods images](https://github.com/bsherman/ublue-kmods)
  - Only on Silverblue: Gnome specific packages
    - gnome shell extensions (appindicator, blur-my-shell, dash-to-dock, gsconnect)
    - gsconnect (plus dependancies)
  - On Kinoite and Vauxite:
    - zenity (used in ublue-firstboot script, available by default in Silverblue)
- Sets faster timeout on systemd waiting for shutdown
- Sets some a few custom gnome settings (see etc/dconf)

## Applications

- Unlike the [ublue base image](https://github.com/ublue-os/base), flatpak applications are installed system wide, but are they are still not on the base image, as they install to /var.
- Also unlike the [ublue base image](https://github.com/ublue-os/base), the "first run script" only executes for the default user which first logs into the system. We still use that process to customize flatpak refs and install default apps, but it only needs to run once as we install those apps to system.
- Custom apps installed on all images:
  - Mozilla Firefox
  - Brave Browser
  - DejaDup
  - Flatseal
  - Libreoffice
  - Piper (mouse manager)
  - and the Celluloid Media Player (video)
- Custom apps installed only on Silverblue (Gnome):
  - Extension Manager
  - Font Downloader
  - Geary
  - Rhythmbox Media Player (music)
  - Sound Recorder
- Core GNOME Applications are installed from Flathub (only on Silverblue image):
  - GNOME Calculator, Calendar, Characters, Connections, Contacts, Evince, Firmware, Logs, Maps, NautilusPreviewer, TextEditor, Weather, baobab, clocks, eog, and font-viewer
- Lightly-tested scripts for easily enabling/disabling LUKS auto-unlock using TPM2.
  - `luks-enable-tpm2-autounlock` - backup `/etc/crypttab` and `systemd-cryptenroll`s TPM2 for unlock; requires existing LUKS2 password
  - `luks-disable-tpm2-autounlock` - restores the backup of `/etc/crypttab` and safely `systemd-cryptenroll` wipes TPM2 unlock slot

## Further Customization

A `just` task runner default config is included for further customization after first boot.
It will copy the template from `/etc/justfile` to your home directory.
After that run the following commands:

- `just` - Show all tasks, more will be added in the future
- `just bios` - Reboot into the system bios (Useful for dualbooting)
- `just changelogs` - Show the changelogs of the pending update
- `just enable-secure-boot-akmods-custom` - use mokutil to import akmods-custom key for SecureBoot loading of xone/xpadneo drivers (must follow steps after reboot to import the key)
- `just enable-secure-boot-akmods-nvidia` - use mokutil to import akmods-custom key for SecureBoot loading of nvidia drivers (must follow steps after reboot to import the key)
- `just enable-nvidia-drivers` - set kernel boot args to enable nvidia drivers (needs a reboot)
- `just update` - Update rpm-ostree, flatpaks, and distroboxes in one command
- Set up distroboxes for the following images:
  - `just distrobox-boxkit`
  - `just distrobox-debian`
  - `just distrobox-fedora`
  - `just distrobox-opensuse`
  - `just distrobox-ubuntu`
- Install various flatpak collections:
  - `just setup-flatpaks` - Install a selection of flatpaks (in my case, usually on parents' laptops but not kids')
  - `just setup-media-flatpaks` - Install Audacity, Inkscape, Kdenlive, Krita, and OBS
  - `just setup-other-flatpaks` - Install misc stuff mostly used only by me amongst my family
  - `just setup-gaming-educational` - Install kid friendly drawing, math, programming, and typing games
  - `just setup-gaming-light` - Install simple games like crosswords, solitaire(cards), mines, bejeweled/tetris clones
  - `just setup-gaming-linux` - Install Linux/Tux games plus a Tron/lightcycle game
  - `just setup-gaming-minecraft` - Install PrismLauncher (Minecraft for Java) and Bedrock Edition launcher
  - `just setup-gaming-serious` - Install Steam, Heroic Game Launcher, Bottles, and community builds of Proton.
  - `just setup-flatpak-overrides-gaming` - Enable MangoHud by default (hit right Shift-F12 to toggle), and enable Bottles to create apps
  - `just setup-flatpak-overrides-pwa` - Enable Chromium browsers to create apps

Check the [just website](https://just.systems) for tips on modifying and adding your own recipes.


## Usage

Warning: This is an experimental feature and should not be used in production (yet), however it's pretty close)

    # pick any one of these
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-custom:37
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-nvidia-custom:37
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/kinoite-custom:37
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/kinoite-nvidia-custom:37
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/vauxite-custom:37
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/vauxite-nvidia-custom:37

We build date tags as well, so if you want to rebase to a particular day's release:
  
    # pick any one of these
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-custom:20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-nvidia-custom:20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/kinoite-custom:20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/kinoite-nvidia-custom:20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/vauxite-custom:20230302
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/vauxite-nvidia-custom:20230302

The `latest` tag will automatically point to the latest stable build, but I suggest using version 37, 38, etc as they become available to avoid surprise upgrades.

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the appropriate command:

    cosign verify --key cosign.pub ghcr.io/bsherman/silverblue-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/silverblue-nvidia-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/kinoite-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/kinoite-nvidia-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/vauxite-custom
    cosign verify --key cosign.pub ghcr.io/bsherman/vauxite-nvidia-custom
