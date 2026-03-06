#!/bin/bash
set -ouex pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "::group::Executing basic stuff"
trap 'echo "::endgroup::"' EXIT

# install base packages

PACKAGES=(
    "podman"
    "distrobox"
    "just"
    "git"
    "bazaar"
    "flatpak"
)

pacman -S --needed --noconfirm "${PACKAGES[@]}"
pacman -S --clean --noconfirm