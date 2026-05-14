#!/usr/bin/env bash
set -euxo pipefail

pacman-key --init
pacman-key --populate archlinux
curl -s https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | pacman-key --add -

pacman-key --lsign-key 56C464BAAC421453
cat >> /etc/pacman.conf <<EOF

[linux-surface]
Server = https://pkg.surfacelinux.com/arch/
EOF

pacman -Syu --noconfirm

pacman -Rns --noconfirm linux
pacman -S --noconfirm \
    linux-surface \
    linux-surface-headers \
    linux-firmware-intel \
    linux-surface-secureboot-mok \
    iptsd

# build initramfs

KVER=$(basename /usr/lib/modules/*)

mkdir -p /var/tmp
chmod 1777 /var/tmp

cat >/etc/dracut.conf.d/bootc.conf <<EOF
hostonly="no"
add_dracutmodules+=" systemd ostree btrfs "
EOF

dracut \
  --force \
  --kver "${KVER}" \
  --no-hostonly \
  --reproducible \
  --add ostree \
  "/boot/initramfs-${KVER}.img"

cp "/usr/lib/modules/${KVER}/vmlinuz" "/boot/vmlinuz-${KVER}" || true

