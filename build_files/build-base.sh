#!/usr/bin/bash
# shellcheck disable=SC1091

set -ouex pipefail

cp -r /ctx/just /tmp/just
cp /ctx/packages.json /tmp/packages.json

rsync -rvK /ctx/system_files/shared/ /
rsync -rvK /ctx/system_files/"${BASE_IMAGE_NAME}"/ /

/ctx/build_files/cache_kernel.sh
/ctx/build_files/copr-repos.sh
/ctx/build_files/install-akmods.sh
/ctx/build_files/packages.sh
/ctx/build_files/nvidia.sh
/ctx/build_files/1password.sh
/ctx/build_files/docker-ce.sh
/ctx/build_files/waydroid.sh
/ctx/build_files/fetch-install.sh
/ctx/build_files/image-info.sh
/ctx/build_files/systemd.sh
/ctx/build_files/custom-changes.sh
/ctx/build_files/initramfs.sh
/ctx/build_files/bootc.sh
/ctx/build_files/cleanup.sh
