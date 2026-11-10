# AquaOS

A Debian-based Linux desktop project with an AquaOS identity and a translucent, macOS-inspired visual style. This is an independent project and uses no proprietary Apple assets.

## Status
This starter repository contains an initial Debian Live Build configuration and CI workflow. A successful CI run should produce bootable Debian Live ISO artifacts; these are development images, not a finished AquaOS release.

The first image uses XFCE, Thunar, common thumbnail/preview tools, and archive utilities. A full Finder-like file manager, broad Quick Look implementation, custom dock, cursor animations, and branded boot animation remain future work.

## Targets
- `amd64`: standard 64-bit PC image.
- `i386`: best-effort 32-bit PC image based on Debian 12 (Bookworm). Cross-architecture builds need testing.

## Local build (Debian 12 build host)
```bash
sudo apt update
sudo apt install -y live-build debootstrap xorriso squashfs-tools \
  grub-pc-bin grub-efi-amd64-bin mtools dosfstools qemu-user-static
sudo bash build/build-iso.sh amd64
# Experimental:
sudo bash build/build-iso.sh i386
```

## GitHub Actions
The workflow in `.github/workflows/build-isos.yml` can be run manually from Actions. It builds each architecture independently and uploads the resulting ISO and SHA-256 checksum as artifacts.

## License
Project configuration and original AquaOS theme files are MIT licensed. Installed packages retain their own licenses.
