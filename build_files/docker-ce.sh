#!/usr/bin/env bash

set -euox pipefail

# Setup repo
cat << EOF > /etc/yum.repos.d/docker-ce.repo
[docker-ce-stable]
name=Docker CE Stable
baseurl=https://download.docker.com/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF

rpm-ostree install \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# prefer to have docker-compose available for legacy muscle-memory
ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose

systemctl enable docker.socket

rm -f /etc/yum.repos.d/docker-ce.repo