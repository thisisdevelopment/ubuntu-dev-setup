#!/usr/bin/env sh

if [ -z "${WIRELESS_SSID}" -o -z "${WIRELESS_PASSWORD}" ]; then
    exit 0
fi

dev=$(ls /sys/class/ieee80211/*/device/net/ | head -n 1)
sudo ip link set dev $dev up
sudo nmcli d wifi connect "$WIRELESS_SSID" password "$WIRELESS_PASSWORD"

