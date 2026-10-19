#!/usr/bin/env bash
# VLA (GR00T + LeRobot) steps that need sudo. Usage: sudo bash ~/setup-sudo-vla.sh
set -euo pipefail
U=${SUDO_USER:-pilsu}
apt-get update
# NVPL LAPACK/BLAS (required by GR00T's Jetson-AI-Lab torch wheel), ffmpeg (torchcodec / video)
apt-get install -y libnvpl-lapack0 libnvpl-blas0 ffmpeg python3-dev
# Serial access to SO-101 Feetech bus servo boards (/dev/ttyACM*) without sudo
usermod -aG dialout "$U"
echo "Done. Log out/in (or reboot) for the dialout group to take effect."
