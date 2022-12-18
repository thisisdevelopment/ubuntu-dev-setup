#!/usr/bin/env sh

set -ux

{

dev=$(ls /sys/class/ieee80211/*/device/net/ | head -n 1)
sudo ip link set dev $dev up
sudo nmcli d wifi connect "$WIRELESS_SSID" password "$WIRELESS_PASSWORD"

user=$(tail -n 1 /etc/passwd | cut -f1 -d':')

usermod -aG docker $user

docker run --name docker-hoster --restart=unless-stopped -d -v /var/run/docker.sock:/tmp/docker.sock -v /etc/hosts:/tmp/hosts thisisdevelopment/docker-hoster

cd /tmp
tb_releases_url='https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release'
download_url=$(curl --silent $tb_releases_url | jq --raw-output '.TBA[0].downloads.linux.link')
curl --output jetbrains-toolbox.tgz --progress-bar --location $download_url
tar -C /home/$user/bin --strip-components=1 --extract --verbose --file jetbrains-toolbox.tgz
rm jetbrains-toolbox.tgz

apt-get update
apt-get upgrade -y

fwupdmgr get-updates -y
fwupdmgr update -y

# Cleanup
rm /root/post-install-user.sh

} >/tmp/post-install-user.out 2>/tmp/post-install-user.err
