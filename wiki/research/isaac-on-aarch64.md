---
type: Research
title: Isaac Sim and Isaac Lab on aarch64
description: Install paths for Isaac Sim/Lab on DGX Spark per official docs, and which one was verified.
tags: [isaac-sim, isaac-lab, aarch64, research]
timestamp: 2026-10-19T02:30:00Z
---

# Isaac Sim and Isaac Lab on aarch64

Checked 2026-10-19.

| Source | What it says |
| --- | --- |
| [Isaac Lab v3.0.0-EA install docs](https://isaac-sim.github.io/IsaacLab/v3.0.0-EA/source/setup/installation/index.html) | Isaac Sim 5.1 and older unsupported; use 6.1 + Python 3.12. Spark needs CUDA 13, driver 580.142 recommended, the apt packages above, `LD_PRELOAD` libgomp. Only the source-build path has explicit aarch64 steps. |
| [Isaac Lab releases](https://github.com/isaac-sim/IsaacLab/releases) | v2.3.0 introduced DGX Spark support (multi-arch Docker, CUDA 13 on ARM). v3.0.0-beta2 added torch 2.10 cu130 aarch64 wheels. v3.0.0-EA (2026-09-16) targets Isaac Sim 6.1. |
| [NVIDIA dgx-spark-playbooks: isaac](https://github.com/NVIDIA/dgx-spark-playbooks/blob/main/nvidia/isaac/README.md) | Builds Isaac Sim from source for `linux-aarch64` with GCC 11. |
| [Arm learning path](https://learn.arm.com/learning-paths/laptops-and-desktops/dgx_spark_isaac_robotics/2_isaac_installation/) | Source build, then `./isaaclab.sh -p scripts/environments/list_envs.py` to verify. |
| pypi.nvidia.com (checked directly) | `isaacsim` 6.1.0.0 and 6.2.0.0 have `manylinux_2_35_aarch64` wheels. |

**Verified here:** the pip-wheel path (`uv sync --extra isaacsim`) works on DGX OS 7.2.3 with driver
580.178.04, newer than the recommended 580.142. See [the decision](../decisions/pip-wheels-over-source-build.md).
