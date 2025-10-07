#!/bin/bash
# eos-snapshots create-snapshot v1

# Do NOT edit the first two lines
# This script is used to create btrfs snapshots on EndeavourOS systems installed on btrfs using the default subvolume layout
# Usage: create-snapshot.sh <subvolume> <directory>
# Creates a new snapshot of <subvolume> in <directory>

# might be running as root so better be safe
set -e

# check correct usage
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <subvolume> <directory>" "$0" >&2
  exit 2
fi

subvolume="$1"
directory="$2"
safe_name=$(echo "$subvolume" | tr '/' '_')

# check if directory exists
if [ ! -d  "$directory" ]; then
  echo "Cannot create snapshot in $(realpath -m "$directory") because directory does not exist" >&2
  exit 2
fi

# check if btrfs is installed
if ! command btrfs version; then
  echo "Could not find btrfs utility, make sure it is installed" >&2
  exit 2
fi

# check if subvolume exists
if ! btrfs subvolume show "$subvolume"; then
  echo "$(realpath -m "$subvolume") is not a btrfs subvolume" >&2
  exit 2
fi

# all checks successfull, make snapshot
btrfs subvolume snapshot "$subvolume" "$directory""$safe_name"-"$(date -Iseconds)" >&2
