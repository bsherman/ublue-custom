#!/bin/sh

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# Get required repos
wget https://copr.fedorainfracloud.org/coprs/rhcontainerbot/bootc/repo/fedora-${RELEASE}/bootc-${RELEASE}.repo -O /etc/yum.repos.d/copr_bootc.repo

if [ "sericea" == "${IMAGE_NAME}" ]; then
    wget https://copr.fedorainfracloud.org/coprs/tofik/nwg-shell/repo/fedora-${RELEASE}/tofik-nwg-shell-fedora-${RELEASE}.repo -O /etc/yum.repos.d/copr_nwg-shell.repo
fi

INCLUDED_PACKAGES=($(jq -r "[(.all.include | (.all, select(.\"$IMAGE_NAME\" != null).\"$IMAGE_NAME\")[]), \
                             (select(.\"$FEDORA_MAJOR_VERSION\" != null).\"$FEDORA_MAJOR_VERSION\".include | (.all, select(.\"$IMAGE_NAME\" != null).\"$IMAGE_NAME\")[])] \
                             | sort | unique[]" /tmp/packages.json))
EXCLUDED_PACKAGES=($(jq -r "[(.all.exclude | (.all, select(.\"$IMAGE_NAME\" != null).\"$IMAGE_NAME\")[]), \
                             (select(.\"$FEDORA_MAJOR_VERSION\" != null).\"$FEDORA_MAJOR_VERSION\".exclude | (.all, select(.\"$IMAGE_NAME\" != null).\"$IMAGE_NAME\")[])] \
                             | sort | unique[]" /tmp/packages.json))


if [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    rpm-ostree install \
        ${INCLUDED_PACKAGES[@]}
else
    echo "No packages to install."
fi

if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    EXCLUDED_PACKAGES=($(rpm -qa --queryformat='%{NAME} ' ${EXCLUDED_PACKAGES[@]}))
fi
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    rpm-ostree override remove \
        ${EXCLUDED_PACKAGES[@]}
fi

# disable installed repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/{copr*,tailscale}.repo

### github direct installs
/tmp/github-release-install.sh twpayne/chezmoi x86_64
/tmp/github-release-install.sh wagoodman/dive amd64
