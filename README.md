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
  - moby-engine (docker's open source version, disabled by default)
  - p7zip
  - ~~[pcp](https://pcp.io/) - Performance Co-pilot monitoring~~ *temporarily disabled until I sort out some issues*
  - powertop
  - shotwell (the flatpak version crashes accessing USB)
  - [tailscale](https://tailscale.com/) (for VPN)
  - tmux
  - tuned (replaces power-profile-daemon)
  - [libvirtd](https://libvirt.org/) and [qemu](https://qemu.org/) backend for running [kvm](https://linux-kvm.org/) VMs (use a client from distrobox, etc)
  - [wezterm](https://wezfurlong.org/wezterm/) cross platform terminal
  - [wireguard-tools](https://www.wireguard.com/) (for more VPN)
  - zenity - for UI scripting
  - Only on Silverblue: Gnome specific packages
    - default font set to Noto Sans
    - gnome shell extensions (appindicator, dash-to-dock, gsconnect, move-clock, no-overview, notifications-reloaded)
    - gsconnect (plus dependancies)
  - Only on Kinoite and Sericea
    - libadwaita(-qt)
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
It will copy a template to your home directory.

After that run `ujust` to get a list of default commands ( a sample set of commands is included below ):

```bash
`ujust
Click here to view the Universal Blue just documentation
Available commands:
 - bios                           # Boot into this device's BIOS/UEFI screen
 - changelogs                     # Show the changelog
 - chsh new_shell                 # Change the user's shell
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
- [Sway (formerly known as Sericea)](https://fedoraproject.org/atomic-desktops/sway/)

### Rebase to Custom

After installation is complete, use the appropriate `rebase` command to install one of these custom images.

*Note: for `IMAGE_NAME` in the commands below, substitute one of these image names:*

- `silverblue-custom`
- `silverblue-nvidia-custom`
- `kinoite-custom`
- `kinoite-nvidia-custom`
- `sericea-custom`
- `sericea-nvidia-custom`


We build `latest` which currently points to Fedora 38 (Fedora 39 will become latest after it releases and related packages have stabilized). Fedora 37 is no longer built here. You can chose a specific version by using the `38` or `39` tag instead of `latest`:

    sudo rpm-ostree rebase \
        ostree-unverified-registry:ghcr.io/bsherman/IMAGE_NAME:latest

We build date tags as well, so if you want to rebase to a particular day's release:

    sudo rpm-ostree rebase \
        ostree-unverified-registry:ghcr.io/bsherman/IMAGE_NAME:39-20240223

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/) using both OpenID Connect with Github and a repo specific keypair. You can verify the signature by running one the following command:

    cosign verify \
        --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
        --certificate-identity-regexp "https://github.com/bsherman/ublue-custom" \
        ghcr.io/bsherman/IMAGE_NAME

    cosign verify --key cosign.pub ghcr.io/bsherman/IMAGE_NAME

