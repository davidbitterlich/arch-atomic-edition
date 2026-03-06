#!/bin/bash
set -ouex pipefail

KDE=(
    "plasma-meta"
    "sddm-kcm"
)

GNOME=(
    "gnome-shell"
    "gdm"
)

DESKTOP=$(echo $1 | tr '[:lower:]' '[:upper:]')

packages=""
login_manager=""

case $DESKTOP in
    KDE)
        packages="${KDE[@]}"
        login_manager=sddm
        ;;
    GNOME)
        packages="${GNOME[@]}"
        login_manager=gdm
        ;;
    *)
        echo "Unknown desktop selection!"
        exit 1
        ;;
esac

if [ ! -z "$packages" ]
then
    pacman -S --needed --noconfirm $packages
    pacman -S --clean --noconfirm
    systemctl enable $login_manager
fi