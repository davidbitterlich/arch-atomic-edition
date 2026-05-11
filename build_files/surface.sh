#!/usr/bin/env bash
set -euxo pipefail

curl -s https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | pacman-key --add -

cat >> /etc/pacman.conf <<EOF

[linux-surface]
Server = https://pkg.surfacelinux.com/arch/
EOF

pacman -Syu --noconfirm

pacman -Rns --noconfirm linux linux-headers
pacman -S --noconfirm \
    linux-surface \
    linux-surface-headers \
    linux-firmware-intel \
    linux-surface-secureboot-mok \
    iptsd