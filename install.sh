#!/bin/bash
# eos-snapshots install v1

# Do NOT edit the first two lines
# This script installs the necessary files and sets up the system for snapshots
# We use sensible defaults. If you don't like them, you can easily change them, since all we use are a few bash scripts

set -e

# check if run as root, exit if not
if [[ $EUID -ne 0 ]]; then
    echo "$0 must be run as root."
    exit 2
fi

# check if grub bootloader is used
if ! ls /boot/grub/grub.cfg 2>/dev/null; then
    echo "GRUB bootloader not detected. Exiting."
    exit 2
fi

# check if grub-btrfs and inotify-tools are installed
for pkg in grub-btrfs inotify-tools; do
    if ! pacman -Q $pkg &>/dev/null; then
        echo "$pkg is not installed. Please install it with: sudo pacman -S $pkg"
        exit 2
    fi
done

echo "Have you set up grub-btrfs to your liking? The default location for root snapshots is /.snapshots."
echo "If you have changed this in the grub-btrfs config, you must also update systemd/eos-btrfs-rootsnapshot.service before continuing."
read -p "Is grub-btrfs set up to your liking? (y/n): " answer
if [[ "$answer" != "y" ]]; then
    echo "Exiting. Please update your configuration as needed."
    exit 2
fi

# make sure neither /.snapshots nor /home/.snapshots exist
for dir in /.snapshots /home/.snapshots; do
    if [ -e "$dir" ]; then
        echo "Error: $dir already exists. Please remove or rename it before continuing."
        exit 2
    fi
done

# create /.snapshots and /home/.snapshots subvolumes
btrfs subvolume create /.snapshots
btrfs subvolume create /home/.snapshots

# copy snapshot script
install -m 644 src/create-snapshot.sh /usr/local/sbin/
install -m 644 src/prune-snapshot.sh /usr/local/sbin/

# copy systemd files
install -m 644 systemd/* /etc/systemd/system

# enable grub-btrfsd
systemctl enable --now grub-btrfsd.service

# enable systemd units
systemctl enable --now eos-btrfs-homesnapshot.timer
systemctl enable --now eos-btrfs-rootsnapshot.timer

# ask about pruning
echo "eos-btrfs-snapshots can also prune existing snapshots. By default, the youngest 7 snapshots will be retained"
read -p "Do you wish to activate pruning of the / snapshots? (y/n)" answer
if [[ "$answer" != "y" ]]; then
    systemctl enable --now eos-btrfs-prune-rootsnapshot.timer
    echo "Successfully activated pruning of / snapshots"
fi

read -p "Do you wish to activate pruning of the /home snapshots? (y/n)" answer
if [[ "$answer" != "y" ]]; then
    systemctl enable --now eos-btrfs-prune-rootsnapshot.timer
    echo "Successfully activated pruning of /home snapshots"
fi

echo "Installed successfully"