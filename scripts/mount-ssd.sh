#!/usr/bin/env bash
# Mount an external ext4 SSD at /mnt/ssd and persist it in /etc/fstab.
# Needs sudo. Usage: ./mount-ssd.sh /dev/sda1
set -euo pipefail
DEV=${1:?usage: $0 /dev/sdX1}
MNT=${MNT:-/mnt/ssd}
UUID=$(lsblk -no UUID "$DEV")
[ -n "$UUID" ] || { echo "no filesystem UUID on $DEV" >&2; exit 1; }
sudo mkdir -p "$MNT"
# nofail: boot does not hang when the SSD is unplugged
grep -q "$UUID" /etc/fstab || \
  echo "UUID=$UUID $MNT ext4 defaults,nofail,x-systemd.device-timeout=10s 0 2" | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo mount "$MNT"
sudo chown "$USER:$USER" "$MNT"
df -hT "$MNT"
