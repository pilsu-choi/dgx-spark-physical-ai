#!/usr/bin/env bash
# Point every cache Isaac Sim, Isaac Lab, uv and PyTorch write to at the SSD,
# so the internal NVMe stays clean. Existing contents are moved, not lost.
set -euo pipefail
S=${SSD:-/mnt/ssd}/cache
link() { # $1 = path under $HOME, $2 = directory on the SSD
  mkdir -p "$2"
  if [ -e "$1" ] && [ ! -L "$1" ]; then cp -a "$1"/. "$2"/; rm -rf "$1"; fi
  mkdir -p "$(dirname "$1")"
  ln -sfn "$2" "$1"
}
link ~/.cache/uv          $S/uv
link ~/.cache/pip         $S/pip
link ~/.cache/ov          $S/ov
link ~/.cache/warp        $S/warp
link ~/.cache/huggingface $S/huggingface
link ~/.cache/torch       $S/torch
link ~/.cache/nvidia      $S/nvidia
link ~/.local/share/ov    $S/ov-data
link ~/.local/share/uv    $S/uv-data   # uv-managed Python interpreters
link ~/.nvidia-omniverse  $S/nvidia-omniverse
link ~/.nv                $S/nv        # CUDA JIT ComputeCache
ls -la ~/.cache | grep -- '->'
