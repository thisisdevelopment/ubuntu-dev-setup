#!/usr/bin/env sh

# encrypt boot partition

tar -C /boot --acls --xattrs --one-file-system -cf /tmp/boot.tar .

bootdev=$(cat /proc/mounts | grep "/boot " | cut -f1 -d' ')
uuid=$(blkid -o value -s UUID $bootdev)

umount /boot/efi
umount /boot

echo "PleaseChangeMe" | cryptsetup -q luksFormat $bootdev -
echo "boot_crypt UUID=$uuid none luks,discard" | tee -a /etc/crypttab

