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
- firmware updates are installed after user setup

# WARNING

Be very careful ... the generated installer image will wipe your whole disk when booted!!!! 

# Usage

Needs docker + usb-creator-gtk
```
./build.sh
```

# Credits

- https://github.com/Nitrokey/ubuntu-oem and https://askubuntu.com/a/1403669 for the image creation 
- https://eric.mink.li/publications/preseeding.html
- https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019 and https://cryptsetup-team.pages.debian.net/cryptsetup/encrypted-boot.html for the full disk encryption

