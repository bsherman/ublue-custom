# Create a Fedora (bsherman custom) container
distrobox-fedora-custom:
  distrobox create --nvidia --image ghcr.io/bsherman/fedora-toolbox-custom:FEDORA_MAJOR_VERSION -n fedora-custom -Y
