#!/usr/bin/env bash

set -e

curp=$(dirname "$0")

# load .env
if [ -f "$curp/.env" ]; then
  source "$curp/.env"
else
  echo "File $curp/.env does not exist!"
  echo "Copy $curp/.env.example as $curp/.env and edit it first!"
  exit 1
fi

: ${AAI_FORMAT:=1}
: ${AAI_MNT:=/mnt}
: ${AAI_DEVICE:=/dev/vda}
: ${AAI_PARTITION_END_VALUE:=0}
: ${AAI_SKIP_INIT:=no}
: ${AAI_PACMAN_CACHE_MOUNT_CMD:='mount -o defaults,timeo=900,retrans=5,vers=3 -t nfs 10.40.30.45:/mnt/HD/HD_a2/pacman'}
: ${AAI_MIRROR:=yes}
: ${AAI_HOSTNAME:=vm-test}
: ${AAI_DOMAIN:=iliyan87.com}
: ${AAI_TIMEZONE:=Europe/Sofia}
: ${AAI_HYBRID_MODE:=1}

my_setup_fs() {
  if [ "${AAI_FORMAT}" -eq "1" ]; then
    if [ "${AAI_HYBRID_MODE}" -eq 1 ]; then
      : ${AAI_PARTITION:=/dev/vda3}
      : ${AAI_PARTITION_ESP:=/dev/vda2}
      : ${AAI_PARTITION_MBR:=/dev/vda1}
      # as explained in https://wiki.archlinux.org/title/Multiboot_USB_drive#Hybrid_UEFI_GPT_+_BIOS_GPT/MBR_boot
      sgdisk -o /dev/vda -n 1:2048s:4095s -n 2:4096s:1052671s -n 3:1052672s:"${AAI_PARTITION_END_VALUE}" -t "1:EF02" -t "2:EF00" -t "3:8300" "${AAI_DEVICE}"
      echo 'r,h,1 2 3,N,EF,N,EF,N,83,Y,x,h,w,Y' | tr ',' '\n' | gdisk "${AAI_DEVICE}"
    else
      : ${AAI_PARTITION:=/dev/vda2}
      : ${AAI_PARTITION_ESP:=/dev/vda1}
      sgdisk -o /dev/vda -n 1:2048s:1050623s -n 2:1050624s:"${AAI_PARTITION_END_VALUE}" -t "1:EF00" -t "2:8300" "${AAI_DEVICE}"
    fi
    mkfs.fat -F 32 "${AAI_PARTITION_ESP}"
    mkfs.ext4 -F "${AAI_PARTITION}"
  fi
  mountpoint -q "${AAI_MNT}" || mount ${AAI_PARTITION} "${AAI_MNT}"
  mkdir -pv "${AAI_MNT}/boot" "${AAI_MNT}/efi"
  mountpoint -q "${AAI_MNT}/efi" || mount ${AAI_PARTITION_ESP} "${AAI_MNT}/efi"
}

my_setup_pacman() {
  if [ -n "${AAI_PACMAN_CACHE_MOUNT_CMD}" ]; then
    mountpoint -q /var/cache/pacman/pkg || ${AAI_PACMAN_CACHE_MOUNT_CMD} /var/cache/pacman/pkg
  fi

  # fix for older archiso file - update database and keyring first
  pacman -Syv --noconfirm archlinux-keyring

  if [ "${AAI_MIRROR}" == "yes" ]; then
    cat >/etc/pacman.d/mirrorlist <<'EOF'
## Bulgaria
Server = http://mirror.host.ag/archlinux/$repo/os/$arch
Server = http://mirrors.netix.net/archlinux/$repo/os/$arch
Server = http://mirrors.uni-plovdiv.net/archlinux/$repo/os/$arch
Server = https://mirrors.uni-plovdiv.net/archlinux/$repo/os/$arch

## United States
Server = http://mirrors.kernel.org/archlinux/$repo/os/$arch

EOF
  fi

  if [ "${AAI_SKIP_INIT}" == "no" ]; then
    if [ "$(cat /etc/hostname | head -n 1 | tr -d '\n ')" == "archiso" ]; then
      # do not use host cache on arch iso
      pacstrap "${AAI_MNT}" base base-devel
    else
      pacstrap -c "${AAI_MNT}" base base-devel
    fi
  fi

  # install packages
  arch-chroot "${AAI_MNT}" pacman -S --noconfirm --ask 4 \
    amd-ucode cronie dhcpcd efibootmgr gcr-4 grub intel-ucode linux linux-firmware mkinitcpio netctl nfs-utils openresolv openssh rsync vim python
}

my_setup_locale() {
  ln -sf "${AAI_MNT}"/usr/share/zoneinfo/"${AAI_TIMEZONE}" /etc/localtime
  cat >"${AAI_MNT}"/etc/locale.gen <<'EOF'
en_US.UTF-8 UTF-8
bg_BG.UTF-8 UTF-8
C.UTF-8 UTF-8
EOF

  echo "LANG=en_US.UTF-8" >"${AAI_MNT}"/etc/locale.conf
  echo "LC_COLLATE=C" >>"${AAI_MNT}"/etc/locale.conf
  echo "$AAI_HOSTNAME" >"${AAI_MNT}"/etc/hostname
  echo "127.0.1.1 ${AAI_HOSTNAME}.${AAI_DOMAIN} ${AAI_HOSTNAME}" >>"${AAI_MNT}"/etc/hosts

  arch-chroot "${AAI_MNT}" <<EOF
set -o errexit

locale-gen

# cron service
systemctl enable cronie.service

EOF
}

my_setup_ssh() {
  timedatectl set-ntp true

  arch-chroot "${AAI_MNT}" <<EOF
set -o errexit

# dhcp is needed before using netctl
systemctl enable dhcpcd.service

# ssh daemon
systemctl enable sshd.service

# ssh-agent via gcr-4 package
systemctl --global enable gcr-ssh-agent.socket

# ensure time is correct
systemctl enable systemd-timesyncd.service
hwclock --systohc

EOF

  mkdir -pv "${AAI_MNT}"/root/.ssh
  chmod 0700 "${AAI_MNT}"/root/.ssh
  [ -f "$curp/root_authorized_keys" ] &&
    cp "$curp/root_authorized_keys" "${AAI_MNT}"/root/.ssh/authorized_keys
}

my_setup_boot() {
  genfstab -U "${AAI_MNT}" >"${AAI_MNT}"/etc/fstab

  arch-chroot "${AAI_MNT}" mkinitcpio -p linux

  cat >>"${AAI_MNT}"/etc/grub.d/40_custom <<'EOF'
#!/bin/sh
exec tail -n +3 $0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.

menuentry "System shutdown" {
	echo "System shutting down..."
	halt
}

menuentry "System restart" {
	echo "System rebooting..."
	reboot
}

EOF

  cat >>"${AAI_MNT}"/etc/default/grub <<'EOF'
GRUB_DEFAULT=saved
GRUB_TIMEOUT=5
GRUB_SAVEDEFAULT="true"
GRUB_DISABLE_SUBMENU=y
GRUB_CMDLINE_LINUX_DEFAULT="quiet i915.modeset=0"
EOF

  grub-install --target=x86_64-efi --recheck --removable --efi-directory=/mnt/efi --boot-directory=/mnt/boot --bootloader-id=GRUB
  if [ "${AAI_HYBRID_MODE}" -eq 1 ]; then
    grub-install --target=i386-pc --recheck --boot-directory=/mnt/boot "${AAI_DEVICE}"
  fi

  arch-chroot "${AAI_MNT}" <<EOF
grub-mkconfig -o /boot/grub/grub.cfg
EOF
}

my_setup_fs

my_setup_pacman

my_setup_locale

my_setup_ssh

my_setup_boot
