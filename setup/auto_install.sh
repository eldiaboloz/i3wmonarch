#!/bin/bash
# update/sync/upgrade host installation first
# pacaur -Syuv
# ensure install scripts are current
pacaur -S arch-install-scripts
# /dev/sda one single partition 100%
parted -s /dev/sda mklabel msdos
parted -s /dev/sda mkpart primary 0% 100%
mkfs.ext4 /dev/sda1

# mount all to /auto
pacstrap /auto base base-devel
genfstab -U /auto >> /auto/etc/fstab
arch-chroot /auto

# inside chroot
ln -s /usr/share/zoneinfo/Europe/Sofia /etc/localtime


