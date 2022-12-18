# This is Development Ubuntu dev setup

This is a set of scripts / configuration to generate a bootable ubuntu image
that will automatically install ubuntu (LTS) onto the booted PC/laptop with our default dev setup

This setup provides:
- a basic ubuntu desktop LTS install with some extra packages (including chrome + jetbrains toolbox)
- preseeded wireless setup
- full disk encryption (second stage bootloader + root)
- our dev script
- user is automatically added to docker group
- docker-hoster is installed
- latest firmware updates are installed after user setup

# WARNING

Be very careful ... the generated installer image will wipe your whole disk when booted!!!!

After completing the installation as user; the user should run the following command 
to update the default disk encryption password to a personalised one:
```
change-disk-encryption-password
```

# Preparations

This needs docker + usb-creator-gtk to work.

Setup your `.env` (see `.env.example)
```
OEM="TID"
UBUNTU_RELEASE="22.04"
UBUNTU_POINT_RELEASE=".1"
WIRELESS_SSID="<optional wireless ssid>"
WIRELESS_PASSWORD="<optional wireless password>"
INITIAL_DISK_PASSWORD="<your intial disk encryption password>"
```

# Usage

Run the following command
```
./build.sh
```
After the iso is build, this will start `usb-creator-gtk` 
which can be used to "burn" this image onto a flash drive.

# TODO

- verify sha256 sums + gpg for iso
- make sure unpack-iso is removed when a new iso is downloaded
- progress indication for post-user-install
- preseed timezone/keyboard etc in user-install
- skip wireless in user-install
- force user to set new password for disk-encryption
- chrome settings for pipewire to enable video conferencing on ubuntu >= 22.04
- add vscode to default install
- add default desktop settings
  - pin chrome + terminal + libreoffice writer/calc + kazam + gedit + software updater
  - set chrome as default browser
  - autostart flameshot + jetbrains toolbox

# Credits

- https://github.com/Nitrokey/ubuntu-oem and https://askubuntu.com/a/1403669 for the image creation 
- https://eric.mink.li/publications/preseeding.html
- https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019 and https://cryptsetup-team.pages.debian.net/cryptsetup/encrypted-boot.html for the full disk encryption

