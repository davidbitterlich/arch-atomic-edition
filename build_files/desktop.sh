#!/bin/bash
set -ouex pipefail

KDE=(
    "plasma-meta"
    "sddm-kcm"
    "kde-utilities-meta"
    "kde-system-meta"
    "dolphin-plugins"
    "plasma-keyboard"
    "kio-extras"
    "kdeconnect"
    "kdenetwork-filesharing"
    "kio-gdrive"
    "kio-zeroconf"    
)

GNOME=(
    "gnome-shell"
    "gdm"
    "networkmanager"
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

systemctl enable NetworkManager
