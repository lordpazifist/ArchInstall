#!/bin/bash
#
# preinstall.sh
#
# Script by LordPazifist
# Version 1
# Date 24.08.2022

echo "set install drive to: "
read installDrive

echo "set swap drive: "
read swapDrive

echo "set EFI drive to: "
read efiDrive

# mounte install Drive to /mnt
mount -o noatime,compress=zstd /dev/$installDrive /mnt

#create Subvolumes
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/data
btrfs subvolume create /mnt/snapshots

#unmount drive
umount /mnt

#mount subvolumes
mount -o noatime,compress=zstd,subvol=root /dev/$installDrive /mnt
mount --mkdir -o noatime,compress=zstd,subvol=home /dev/$installDrive /mnt/home
mount --mkdir -o noatime,compress=zstd,subvol=snapshots /dev/$installDrive /mnt/.snapshots
mount --mkdir /dev/$efiDrive /mnt/boot/efi
swapon /dev/$swapDrive

sudo pacman -Sy archlinux-keyring

#Base install
pacstrap /mnt base base-devel btrfs-progs efibootmgr git grep grub \
intel-ucode iwd linux-firmware linux linux-zen linux-headers \
linux-zen-headers nano networkmanager sudo xdg-user-dirs xdg-user-dirs-gtk \
xdg-utils xf86-input-synaptics

genfstab -U /mnt > /mnt/etc/fstab
#remark: genfstab includes subvolid into fstab. Might create problems during rollback with snapper.

#preinstall finished. Continue with arch-chroot
