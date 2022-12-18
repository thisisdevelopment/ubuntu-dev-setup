#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "This script should be run as root"
    exit 1
fi

root="/dev/$(lsblk -t -s -P | grep -A 2 "vg.*-root" | tail -n 1 | sed 's/NAME="\([^"]*\)".*$/\1/')"
boot="/dev/$(lsblk -t -s -P | grep -A 1 "boot_crypt" | tail -n 1 | sed 's/NAME="\([^"]*\)".*$/\1/')"

read -s -p "Old disk encryption password:" password_old || exit 1
echo ""
read -s -p "New disk encryption password:" password_new || exit 1
echo ""
read -s -p "New disk encryption password (verify):" password_repeat || exit 1
echo ""
if [ "$password_new" != "$password_repeat" ]; then
    echo "passwords do not match"
    exit 1
fi
if [ ${#password_new} -lt 12 ]; then
    echo "password should be at least 12 characters"
    exit 1
fi

old_key_file=$(mktemp)
chmod 0600 $old_key_file
echo -n "$password_old" > $old_key_file
echo -n "$password_new" | cryptsetup luksChangeKey -S 0 -d $old_key_file $root -
echo -n "$password_new" | cryptsetup luksChangeKey --pbkdf-force-iterations 500000 -S 0 -d $old_key_file $boot -
rm $old_key_file

echo "Successfully update your disk encryption password. Do not forget to update it in your password manager!"
