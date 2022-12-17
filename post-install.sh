#!/usr/bin/env sh

# Prepare for shipping immediately
oem-config-prepare --quiet

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i ./google-chrome-stable_current_amd64.deb
rm ./google-chrome-stable_current_amd64.deb

apt-get update
apt-get install -y libfuse2 docker.io docker-compose openvpn ssh-askpass git curl diffstat diffutils flameshot jq net-tools whois mtr ripgrep inkscape gzip findutils htop rsync joe

# Cleanup
rm /root/post-install.sh
