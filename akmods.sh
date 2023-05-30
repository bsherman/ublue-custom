#!/bin/sh

set -ouex pipefail

wget https://negativo17.org/repos/fedora-steam.repo -O /etc/yum.repos.d/fedora-steam.repo

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,modular,updates-modular}.repo

# enable rpmfusion only if it was disabled
for REPO in $(ls /etc/yum.repos.d/rpmfusion-{,non}free{,-updates}.repo); do
  echo $REPO
  if [[ "$(grep enabled=1 ${REPO} > /dev/null; echo $?)" == "1" ]]; then \
    sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' ${REPO}
  fi
done

KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
# install stuff
rpm-ostree install --idempotent \
  /tmp/akmods/xone/kmod-xone-${KERNEL_VERSION}-*.rpm \
  /tmp/akmods/xpadneo/kmod-xpadneo-${KERNEL_VERSION}-*.rpm \
  /tmp/akmods-custom-key/rpmbuild/RPMS/noarch/akmods-custom-key-*.rpm \

# cleanup stuff
rm -rf /etc/yum.repos.d/fedora-steam.repo
