#!/usr/bin/env sh

echo "--- Encrypting boot partition ---"

# backup boot partition
tar -C /target/boot --acls --xattrs --one-file-system -cf /target/tmp/boot.tar .

cat /proc/mounts

# gather partition info
lvmroot="/dev/$(lsblk -t -s -P | grep -A 2 "vg.*-root" | tail -n 1 | sed 's/NAME="\([^"]*\)".*$/\1/')"
bootdev=$(cat /proc/mounts | grep "/target/boot " | cut -f1 -d' ')
efidev=$(cat /proc/mounts | grep "/target/boot/efi " | cut -f1 -d' ')
uuidboot=$(blkid -o value -s UUID $bootdev)

# encrypt boot
umount /target/boot/efi
umount /target/boot

# setup luks1 boot partition with less iterations as the grub implementation is slow
echo -n "${INITIAL_DISK_PASSWORD}" | cryptsetup -q luksFormat --type=luks1 --pbkdf-force-iterations 500000 $bootdev  -
echo -n "${INITIAL_DISK_PASSWORD}" | cryptsetup open $bootdev boot_crypt -
mkfs.ext4 -U $uuidboot -L boot /dev/mapper/boot_crypt

# create keyfile
mkdir /target/etc/luks
dd if=/dev/urandom of=/target/etc/luks/boot_os.keyfile bs=512 count=1
chmod 0400 /target/etc/luks/boot_os.keyfile

# add keyfile to boot + root
echo -n "${INITIAL_DISK_PASSWORD}" | cryptsetup -d - -q luksAddKey $bootdev /target/etc/luks/boot_os.keyfile
echo -n "${INITIAL_DISK_PASSWORD}" | cryptsetup -d - -q luksAddKey $lvmroot /target/etc/luks/boot_os.keyfile

# update config
echo "boot_crypt UUID=$(blkid -o value -s UUID $bootdev) none luks,discard" | tee -a /target/etc/crypttab
sed -i 's|none |/etc/luks/boot_os.keyfile key-slot=1,|' /target/etc/crypttab
echo "GRUB_ENABLE_CRYPTODISK=y" > /target/etc/default/grub.d/local.cfg
echo "KEYFILE_PATTERN=/etc/luks/*.keyfile" >> /target/etc/cryptsetup-initramfs/conf-hook
echo "UMASK=0077" >> /target/etc/initramfs-tools/initramfs.conf

echo "--- Updating boot loader ---"

mount /dev/mapper/boot_crypt /target/boot
mount $efidev /target/boot/efi
for n in proc sys dev etc/resolv.conf; do
    mount --rbind /$n /target/$n
done

# restore boot partition contents + update bootloader
chroot /target tar -C /boot --acls --xattrs -xf /tmp/boot.tar
chroot /target update-initramfs -u -k all
chroot /target update-grub
chroot /target grub-install
