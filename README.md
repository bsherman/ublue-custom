# silverblue-custom

[![build-ublue](https://github.com/bsherman/silverblue-custom/actions/workflows/build.yml/badge.svg)](https://github.com/bsherman/silverblue-custom/actions/workflows/build.yml)

A custom Fedora Silverblue image which is mostly stock, plus the few things that are needed to make life good on my family's laptops.

## What is this?

This is a Fedora Silverblue image customized how I want, based on the great work by [team ublue os](https://github.com/ublue-os).

## Usage

Warning: This is an experimental feature and should not be used in production (yet), however it's pretty close)

    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-custom:latest

We build date tags as well, so if you want to rebase to a particular day's release:
  
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-custom:20230206

The `latest` tag will automatically point to the latest build. 

## Features

- Uses my [silverblue-kmods image](https://github.com/bsherman/silverblue-kmods) as a base (stock Silverblue, plus nvidia and xpadneo drivers are included)
- Removes Firefox from the base image
- Adds the following packages to the base image:
  - distrobox
  - evolution (needed to easily add CalDAV/CardDAV sources for Geary/Calendar)
  - gnome-tweaks
  - gnome shell extensions (appindicator, dash-to-dock, gsconnect)
  - gsconnect (dependancies)
  - just
  - ratbagd (for Piper mouse management)
  - shotwell (the flatpak version crashes accessing USB)
  - tailscale
  - wireguard-tools
- Sets automatic staging of updates for the system
- Sets flatpaks to update twice a day
- Copies udev rules from [ublue-os/udev-rules](https://github.com/ublue-os/udev-rules)
- Everything else (desktop, artwork, etc) remains stock

## Applications

- Unlike the [ublue base image](https://github.com/ublue-os/base), flatpak applications are installed system wide, but are they are still not on the base image, as they install to /var.
- Also unlike the [ublue base image](https://github.com/ublue-os/base), the "first run script" only executes for the default user which first logs into the system. We still use that process to customize flatpak refs and install default apps, but it only needs to run once as we install those apps to system.
- Custom apps installed:
  - Mozilla Firefox
  - Brave Browser
  - Geary
  - DejaDup
  - Extension Manager
  - Flatseal
  - Font Downloader
  - Libreoffice
  - Piper (mouse manager)
  - Rhythmbox Media Player (music)
  - Sound Recorder
  - and the Celluloid Media Player (video)
- Core GNOME Applications are installed from Flathub:
  - GNOME Calculator, Calendar, Characters, Connections, Contacts, Evince, Firmware, Logs, Maps, NautilusPreviewer, TextEditor, Weather, baobab, clocks, eog, and font-viewer

## Further Customization

The `just` task runner is included for further customization after first boot.
It will copy the template from `/etc/justfile` to your home directory.
After that run the following commands:

- `just` - Show all tasks, more will be added in the future
- `just bios` - Reboot into the system bios (Useful for dualbooting)
- `just changelogs` - Show the changelogs of the pending update
- Set up distroboxes for the following images:
  - `just distrobox-boxkit`
  - `just distrobox-debian`
  - `just distrobox-opensuse`
  - `just distrobox-ubuntu`
  - `just setup-flatpaks` - Install a selection of flatpaks (in my case, usually on parents' laptops but not kids')
  - `just setup-media-flatpaks` - Install Audacity, Inkscape, Kdenlive, Krita, and OBS
  - `just setup-other-flatpaks` - Install misc stuff mostly used only by me amongst my family
  - `just setup-gaming-educational` - Install kid friendly drawing, math, programming, and typing games
  - `just setup-gaming-light` - Install simple games like crosswords, solitaire(cards), mines, bejeweled/tetris clones
  - `just setup-gaming-linux` - Install Linux/Tux games plus a Tron/lightcycle game
  - `just setup-gaming-minecraft` - Install PrismLauncher (Minecraft for Java) and Bedrock Edition launcher
  - `just setup-gaming-serious` - Install Steam, Heroic Game Launcher, Bottles, and community builds of Proton. MangoHud is installed and enabled by default, hit right Shift-F12 to toggle
  - `just update` - Update rpm-ostree, flatpaks, and distroboxes in one command

Check the [just website](https://just.systems) for tips on modifying and adding your own recipes. 
  
  
## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/bsherman/silverblue-custom
