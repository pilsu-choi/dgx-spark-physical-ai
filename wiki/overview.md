---
type: Overview
title: Overview
description: Hardware, goal, scope and status of the DGX Spark physical-AI setup.
tags: [overview, hardware]
timestamp: 2026-10-19T02:30:00Z
---

# Overview

## Hardware

- **Lenovo ThinkStation PGX** — an OEM DGX Spark: NVIDIA GB10 Grace Blackwell superchip, 20-core
  Arm CPU, **128 GB unified memory** shared by CPU and GPU (about 119 GB visible to the OS).
- DGX OS 7.2.3 (Ubuntu 24.04.5 LTS, **aarch64**), driver 580.178.04, CUDA 13.0.
- Internal 1 TB NVMe for the OS; **external 2 TB Samsung T7 Shield** (USB, ext4) at `/mnt/ssd`.
- Reached over SSH from a Windows 11 + WSL2 laptop on the same LAN ([runbook](runbooks/ssh-access.md)).

## Goal

A working Isaac Sim + Isaac Lab environment for robot learning, plus Cosmos world models, with
**all disk usage on the external SSD** so the internal drive stays clean and the setup is portable.

## Status (2026-10-19)

| Component | State |
| --- | --- |
| External SSD mount + cache redirection | Done ([runbook](runbooks/external-ssd.md)) |
| Isaac Sim 6.1 + Isaac Lab v3.0.0-EA | Installed, Cartpole RL smoke test passes ([runbook](runbooks/isaac-sim-lab.md)) |
| Cosmos3-Nano text-to-video | Works at the official 720p/189-frame setting ([runbook](runbooks/cosmos3-nano.md)) |
| Cosmos3-Nano image-to-video, action, reasoner | Not tested yet ([issue](issues/cosmos-untested-modes.md)) |
| GR00T N1.7 + LeRobot (VLA, SO-101) | Installed; TRT 89–99 ms/call; 2k-step SO-101 fine-tune works open-loop; no robot connected yet ([runbook](runbooks/gr00t-lerobot.md)) |

## Disk layout on the SSD

```
/mnt/ssd/
├── isaac/IsaacLab/        Isaac Lab checkout + .venv (~20 GB, includes Isaac Sim 6.1)
├── isaac/env.sh           environment for running Isaac Lab
├── cosmos/.venv           diffusers + torch for Cosmos (~6 GB)
├── cosmos/out/            generated videos
├── models/Cosmos3-Nano/   model weights (33 GB)
├── vla/Isaac-GR00T/       GR00T N1.7 checkout + .venv + checkpoints/
├── vla/lerobot/           LeRobot checkout + .venv
├── vla/env-*.sh           environments for the groot / lerobot aliases
└── cache/                 uv, pip, Omniverse, warp, HF, torch, CUDA caches (symlinked from $HOME)
```
