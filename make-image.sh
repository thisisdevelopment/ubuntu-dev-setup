#!/usr/bin/env bash

command -v xorriso >/dev/null 2>&1 || { echo >&2 "Please install 'xorriso' first.  Aborting."; exit 1; }
command -v patch >/dev/null 2>&1 || { echo >&2 "Please install 'patch' first.  Aborting."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "Please install 'curl' first.  Aborting."; exit 1; }

set -xe

source .env

# Basic parameters
RELEASE_ISO_FILENAME="ubuntu-${UBUNTU_RELEASE}${UBUNTU_POINT_RELEASE}-desktop-amd64.iso"
CUSTOM_ISO_FILENAME="ubuntu-${UBUNTU_RELEASE}${UBUNTU_POINT_RELEASE}-${OEM}-oem-amd64.iso"
DOWNLOAD_URL="https://mirror.nl.datapacket.com/ubuntu-releases/${UBUNTU_RELEASE}/${RELEASE_ISO_FILENAME}"
UNPACKED_IMAGE_PATH="./unpacked-iso/"
VOLUME_NAME="${OEM} Ubuntu-${UBUNTU_RELEASE}${UBUNTU_POINT_RELEASE}"

if [ ! -f "${RELEASE_ISO_FILENAME}" ]; then
    curl --output ${RELEASE_ISO_FILENAME} --progress-bar --location ${DOWNLOAD_URL}
fi

# Unpack ISO, make data writable
xorriso -osirrox on -indev  "${RELEASE_ISO_FILENAME}" -- -extract / "${UNPACKED_IMAGE_PATH}"
chmod -R u+w unpacked-iso/

unpacked="./unpacked-iso"
./install.sh grub.cfg $unpacked/boot/grub/grub.cfg
./install.sh ubuntu-${UBUNTU_RELEASE}.seed $unpacked/preseed/ubuntu.seed
./install.sh post-install.sh $unpacked/post-install.sh
./install.sh post-install-user.sh $unpacked/post-install-user.sh
./install.sh setup.sh $unpacked/setup.sh
./install.sh encrypt-boot.sh $unpacked/encrypt-boot.sh
./install.sh change-disk-encryption-password.sh $unpacked/change-disk-encryption-password

cp -a skel $unpacked
echo "${VOLUME_NAME}" > $unpacked/.disk/info

args=$(xorriso -indev "${RELEASE_ISO_FILENAME}" -report_el_torito as_mkisofs 2>/dev/null | grep -v "\-V " | grep -v "modification-date" | tr '\n' ' ')
cmd="xorriso -indev \"${RELEASE_ISO_FILENAME}\" -as mkisofs -r -J -V '${VOLUME_NAME}' -o $CUSTOM_ISO_FILENAME $args \"${UNPACKED_IMAGE_PATH}\""
eval "$cmd"

