# Changelog

## 0.1.0 (2023-02-05)

* Copied from ([ublue/base](https://github.com/ublue-os/base) to start my own base image
* Lots of changes to default layered packages, firstboot flatpaks, and justfile managed packages
* Flatpaks installed `--system` not `--user` as this image targets multi-user systems
* `ublue-firstboot` will only run for the default user with `uid==1000`
