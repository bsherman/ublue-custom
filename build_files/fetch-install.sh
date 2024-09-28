#!/usr/bin/bash

set -ouex pipefail

# github direct installs
/ctx/build_files/github-release-install.sh twpayne/chezmoi x86_64

# Starship Shell Prompt
curl -Lo /tmp/starship.tar.gz "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz"
tar -xzf /tmp/starship.tar.gz -C /tmp
install -c -m 0755 /tmp/starship /usr/bin
# shellcheck disable=SC2016
echo 'eval "$(starship init bash)"' >> /etc/bashrc

# Bash Prexec
curl -Lo /usr/share/bash-prexec https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh

# Consolidate Just Files
find /tmp/just -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just
# ensure any just recipes needing fedora version are updated
sed -i "s/FEDORA_MAJOR_VERSION/${FEDORA_MAJOR_VERSION}/" /usr/share/ublue-os/just/60-custom.just
