#!/bin/bash
# eos-snapshots uninstall v1

# Do NOT edit the first two lines
# Uninstall eos-btrfs-snapshots

set -e

# make sure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "$0 must be run as root."
    exit 2
fi

# ask if user is sure they want to uninstall
echo "This script will uninstall eos-btrfs-snapshot. It will NOT delete your snapshots"
read -p "Continue? (y/n)" answer
if [[ "$answer" != "y" ]]; then
    echo "Exiting"
    exit 2
fi

# disable timers
systemctl disable --now eos-btrfs-homesnapshot.timer
systemctl disable --now eos-btrfs-rootsnapshot.timer
systemctl disable --now eos-btrfs-prune-homesnapshot.timer
systemctl disable --now eos-btrfs-prune-rootsnapshot.timer

# remove scripts
rm /usr/local/sbin/create-snapshot.sh
rm /usr/local/sbin/prune-snapshot.sh

# remove systemd timers and services
rm /etc/systemd/system/eos-btrfs-homesnapshot.service
rm /etc/systemd/system/eos-btrfs-homesnapshot.timer
rm /etc/systemd/system/eos-btrfs-rootsnapshot.service
rm /etc/systemd/system/eos-btrfs-rootsnapshot.timer
rm /etc/systemd/system/eos-btrfs-prune-homesnapshot.service
rm /etc/systemd/system/eos-btrfs-prune-homesnapshot.timer
rm /etc/systemd/system/eos-btrfs-prune-rootsnapshot.service
rm /etc/systemd/system/eos-btrfs-prune-rootsnapshot.timer

# done
echo "Successfully uninstalled eos-btrfs-snapshot"