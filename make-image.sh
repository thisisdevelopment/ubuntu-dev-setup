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
UNPACKED_IMAGE_PATH="./unpacked-iso"
VOLUME_NAME="${OEM} Ubuntu-${UBUNTU_RELEASE}${UBUNTU_POINT_RELEASE}"

if [ ! -f "${RELEASE_ISO_FILENAME}" ]; then
    curl --output ${RELEASE_ISO_FILENAME} --progress-bar --location ${DOWNLOAD_URL}
fi

if [ -d "${UNPACKED_IMAGE_PATH}" ]; then
    rm -rf "${UNPACKED_IMAGE_PATH}"
fi

if [ -f "${CUSTOM_ISO_FILENAME}" ]; then
    rm -f "${CUSTOM_ISO_FILENAME}"
fi

# Unpack ISO, make data writable
xorriso -osirrox on -indev  "${RELEASE_ISO_FILENAME}" -- -extract / "${UNPACKED_IMAGE_PATH}/"
chmod -R u+w "${UNPACKED_IMAGE_PATH}"

unpacked="./unpacked-iso"
./install.sh grub.cfg ${UNPACKED_IMAGE_PATH}/boot/grub/grub.cfg
./install.sh ubuntu-${UBUNTU_RELEASE}.seed ${UNPACKED_IMAGE_PATH}/preseed/ubuntu.seed
./install.sh post-install.sh ${UNPACKED_IMAGE_PATH}/post-install.sh
./install.sh post-install-user.sh ${UNPACKED_IMAGE_PATH}/post-install-user.sh
./install.sh setup.sh ${UNPACKED_IMAGE_PATH}/setup.sh
./install.sh encrypt-boot.sh ${UNPACKED_IMAGE_PATH}/encrypt-boot.sh
./install.sh change-disk-encryption-password.sh ${UNPACKED_IMAGE_PATH}/change-disk-encryption-password

cp -a skel ${UNPACKED_IMAGE_PATH}
echo "${VOLUME_NAME}" > ${UNPACKED_IMAGE_PATH}/.disk/info

args=$(xorriso -indev "${RELEASE_ISO_FILENAME}" -report_el_torito as_mkisofs 2>/dev/null | grep -v "\-V " | grep -v "modification-date" | tr '\n' ' ')
cmd="xorriso -indev \"${RELEASE_ISO_FILENAME}\" -as mkisofs -r -J -V '${VOLUME_NAME}' -o $CUSTOM_ISO_FILENAME $args \"${UNPACKED_IMAGE_PATH}\""
eval "$cmd"
