#!/usr/bin/env sh

if [ -n "${WIRELESS_SSID_INSTALL}" -a -n "${WIRELESS_PASSWORD_INSTALL}" ]; then
    dev=$(ls /sys/class/ieee80211/*/device/net/ | head -n 1)
    sudo ip link set dev $dev up
    sudo nmcli d wifi connect "$WIRELESS_SSID_INSTALL" password "$WIRELESS_PASSWORD_INSTALL"
    exit 0
fi

if [ -n "${WIRELESS_SSID}" -a -n "${WIRELESS_PASSWORD}" ]; then
    dev=$(ls /sys/class/ieee80211/*/device/net/ | head -n 1)
    sudo ip link set dev $dev up
    sudo nmcli d wifi connect "$WIRELESS_SSID" password "$WIRELESS_PASSWORD"
    exit 0
fi

