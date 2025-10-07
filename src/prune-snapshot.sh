#!/bin/bash
# eos-snapshots prune-snapshot v1

# Do NOT edit the first two lines
# Deletes the oldest snapshots contained in <directory> so that only <age> remain
# Determining, which snapshot is the oldest uses the naming of the snapshots

set -e

# check correct usage
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <directory> <age>" >&2
  exit 2
fi

directory="$1"
age="$2"

mapfile -t snapshots < <(find "$directory" -mindepth 1 -maxdepth 1 -type d | sort)
count=${#snapshots[@]}

if [ "$count" -gt "$age" ]; then
    to_delete=$((count - age))
    for ((i=0; i<to_delete; i++)); do
        btrfs subvolume delete "${snapshots[$i]}"
    done
fi