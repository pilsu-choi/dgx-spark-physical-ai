#!/usr/bin/env bash
# Install Isaac Lab v3.0.0-EA + Isaac Sim 6.1 (aarch64 pip wheels) on the SSD.
# Prereq (sudo, once):
#   sudo apt install -y python3.12-dev libgl1-mesa-dev libx11-dev libxcursor-dev \
#     libxi-dev libxinerama-dev libxrandr-dev git-lfs
set -euo pipefail
S=${SSD:-/mnt/ssd}
TAG=${ISAACLAB_TAG:-v3.0.0-EA}
command -v uv >/dev/null || curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH=$HOME/.local/bin:$PATH
mkdir -p "$S/isaac" && cd "$S/isaac"
[ -d IsaacLab ] || git clone https://github.com/isaac-sim/IsaacLab.git
cd IsaacLab && git fetch --tags -q && git checkout -q "$TAG"
# pyproject routes torch to the cu130 index on aarch64 automatically
uv sync --extra isaacsim
cp "$(dirname "$0")/env.sh" "$S/isaac/env.sh" 2>/dev/null || true
