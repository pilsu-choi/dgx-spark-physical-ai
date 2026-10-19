---
type: Runbook
title: Isaac Sim 6.1 + Isaac Lab 3.0.0-EA
description: Installing Isaac Sim and Isaac Lab from aarch64 pip wheels with uv, and the smoke test.
tags: [isaac-sim, isaac-lab, uv, aarch64]
timestamp: 2026-10-19T02:30:00Z
---

# Isaac Sim 6.1 + Isaac Lab 3.0.0-EA

## Prerequisites (sudo)

```bash
sudo apt install -y python3.12-dev libgl1-mesa-dev libx11-dev libxcursor-dev \
  libxi-dev libxinerama-dev libxrandr-dev git-lfs
```

Isaac Lab's docs require these on DGX Spark; some Python dependencies (for example `imgui-bundle`)
have no aarch64 wheel and build from source against the X11 headers.

## Install

[scripts/install-isaaclab.sh](../../scripts/install-isaaclab.sh):

```bash
cd /mnt/ssd/isaac
git clone https://github.com/isaac-sim/IsaacLab.git && cd IsaacLab
git checkout v3.0.0-EA
uv sync --extra isaacsim
```

- The repo's `pyproject.toml` routes `torch` to the **cu130** index on aarch64 and pins
  `isaacsim[all,extscache]==6.1.0.0`, which resolves to the `manylinux_2_35_aarch64` wheels.
- `python-preference = "only-managed"`: uv downloads its own Python 3.12, which is why
  `~/.local/share/uv` must also point at the SSD.
- *Measured:* 438 packages resolved, 253 installed, **20 min 20 s** — almost all download time.
  The largest wheel, `isaacsim-extscache-kit`, is 4.7 GB. The resulting `.venv` is about 20 GB.
- Check: `torch 2.11.0+cu130`, `torch.cuda.is_available() == True`, device `NVIDIA GB10`.

## Run

```bash
source /mnt/ssd/isaac/env.sh        # PATH, LD_PRELOAD libgomp, EULA vars, cd into IsaacLab
uv run --extra isaacsim isaaclab train --rl_library rsl_rl \
  --task Isaac-Cartpole-Direct physics=isaacsim_physx agent.max_iterations=20
```

- Without `LD_PRELOAD=/lib/aarch64-linux-gnu/libgomp.so.1` the app prints a shared-library warning
  and exits. [scripts/env.sh](../../scripts/env.sh) sets it.
- `env.sh` also sets `OMNI_KIT_ACCEPT_EULA=YES`, which accepts the NVIDIA EULA non-interactively.
- Headless is the default. Pass `--viz kit`, `--viz newton` or `--viz viser` to see the scene.
- Other physics backends: `physics=newton_mjwarp` (default, no Isaac Sim needed) or
  `physics=ovphysx` with `--extra ovphysx`.

## Smoke test result (*measured*)

Cartpole-Direct, PhysX, rsl_rl, 20 iterations: exit 0, **0.17 s per iteration**, mean reward rising
from −0.11 to 1.67. Raw output: [docs/logs/isaaclab-cartpole-2026-10-18.txt](../../docs/logs/isaaclab-cartpole-2026-10-18.txt).

Expected harmless warnings: `failed to open the default display` (no X server over SSH) and
`IO descriptors are only supported for manager based RL environments`.
