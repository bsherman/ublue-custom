#!/bin/bash
#
# A script to install an RPM from the latest Github release for a project.
#
# ORG_PROJ is the pair of URL components for organization/projectName in Github URL
# example: https://github.com/wez/wezterm/releases
#   ORG_PROJ would be "wez/wezterm"
#
# RPM_PRE is the first part of the rpm's filename
# example: for file "wezterm-20230320_124340_559cb7b0-1.fedora37.x86_64.rpm"
#   RPM_PRE would be "wezterm"
#   NOTE: this may not always match the project name
#
# FILTER is used if there are more than one RPMs which match our arch/noarch.rpm pattern
# example: wezterm builds a lot of rpms, but they are labeled by distro so we can filter
#   FILTER would be "fedora37" to get the RPM build for fedora37

ORG_PROJ=${1}
RPM_PRE=${2}
FILTER=${3}

if [ -z ${ORG_PROJ} ]; then
  echo "$0 ORG_PROJ RPM_PRE are required"
  exit 1
fi

if [ -z ${RPM_PRE} ]; then
  echo "$0 ORG_PROJ RPM_PRE are required"
  exit 2
fi

install() {
  API=${1}
  NAME=${2}
  FILTER=${3}

  #curl -sL ${API} | jq -r '.assets[].browser_download_url' | grep -E 'x64.rpm$|x86_64.rpm$|all.rpm$|noarch.rpm$' | grep "${FILTER}"
  DLS=$(curl -sL ${API} | jq -r '.assets[].browser_download_url' | grep -E 'x64.rpm$|x86_64.rpm$|all.rpm$|noarch.rpm|Linux.rpm$' | grep "${FILTER}")
  for DL in ${DLS}; do
    # WARNING: in case of multiple matches, this only installs the first
    echo "execute: rpm-ostree install \"${DL}\""
    rpm-ostree install "${DL}"
    break
  done
}

install "https://api.github.com/repos/${ORG_PROJ}/releases/latest"  "${RPM_PRE}" "${FILTER}"
