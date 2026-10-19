---
type: Lesson
title: Isaac Lab 3 CLI changes and the libgomp preload
description: The first two Isaac Lab runs failed: missing libgomp preload, then the removed --headless flag.
tags: [isaac-lab, aarch64, cli, lesson]
timestamp: 2026-10-19T02:30:00Z
---

# Isaac Lab 3 CLI changes and the libgomp preload

## 1. libgomp must be preloaded on aarch64

The first `uv run ... isaaclab train` exited with:

```
WARNING: For the application to run, some shared libraries must be
loaded before others ...
    LD_PRELOAD="/lib/aarch64-linux-gnu/libgomp.so.1" <COMMAND>
```

Isaac Lab's docs mention it for aarch64. It now lives in [scripts/env.sh](../../scripts/env.sh). If
OpenMP warnings appear anyway, `unset LD_PRELOAD` first and set only libgomp.

## 2. `--headless` and `--max_iterations` are gone

```
isaaclab: error: unrecognized arguments: --headless
```

Isaac Lab 3.0 replaced the per-script argparse flags with a Hydra CLI (`isaaclab train|play ...`):

| 2.x | 3.0 |
| --- | --- |
| `--headless` | default; use `--viz kit/newton/viser/rerun` to show something |
| `--max_iterations 20` | `agent.max_iterations=20` (Hydra override) |
| `./isaaclab.sh -p scripts/.../train.py` | `uv run isaaclab train --rl_library rsl_rl --task ...` |
| — | `physics=isaacsim_physx` / `newton_mjwarp` / `ovphysx` selects the backend |

Most DGX Spark blog posts predate 3.0 and still show the 2.x flags.
