# silverblue-custom

[![build-ublue](https://github.com/bsherman/silverblue-custom/actions/workflows/build.yml/badge.svg)](https://github.com/bsherman/silverblue-custom/actions/workflows/build.yml)

A custom Fedora Silverblue image which is mostly stock, plus the few things that are needed to make
life good on my family's laptops.

## What is this?

This is a Fedora Silverblue image customized how I want, based on the great work by [team ublue os](https://github.com/ublue-os).

## Usage

Warning: This is an experimental feature and should not be used in production (yet), however it's pretty close)

    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-custom:latest
    
We build date tags as well, so if you want to rebase to a particular day's release:
  
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/bsherman/silverblue-custom:20230207

The `latest` tag will automatically point to the latest build. 

## Features

- Start with a base Fedora Silverblue 37 image
- Removes Firefox from the base image
- Adds the following packages to the base image:
  - distrobox and gnome-tweaks
- Sets automatic staging of updates for the system
- Sets flatpaks to update twice a day
- Everything else (desktop, artwork, etc) remains stock so you can use this as a good starting image

## Applications

- All applications installed per user instead of system wide, similar to openSUSE MicroOS, they are not on the base image. Thanks for the inspiration Team Green!
- Mozilla Firefox, Mozilla Thunderbird, Extension Manager, Libreoffice, DejaDup, FontDownloader, Flatseal, and the Celluloid Media Player
- Core GNOME Applications installed from Flathub
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
- `just setup-flatpaks` - Install a selection of flatpaks, use this section to add your own apps
- `just setup-gaming` - Install Steam, Heroic Game Launcher, OBS Studio, Discord, Boatswain, Bottles, and ProtonUp-Qt. MangoHud is installed and enabled by default, hit right Shift-F12 to toggle
- `just update` - Update rpm-ostree, flatpaks, and distroboxes in one command

Check the [just website](https://just.systems) for tips on modifying and adding your own recipes. 
  
  
## Verification

These images are signed with sisgstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/bsherman/silverblue-custom
