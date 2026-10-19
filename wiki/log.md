---
type: Log
title: Work log
description: Chronological history of the setup work, newest last.
tags: [log, history]
timestamp: 2026-10-19T02:30:00Z
---

# Work log

Times are UTC. Each entry links to the page with the details.

## 2026-10-18

- Machine set up on the home LAN; SSH key auth from Windows. Claude Code, nvm/Node and Codex
  installed user-level (no passwordless sudo).

## 2026-10-19 (from 22:40 UTC on 10-18)

- **22:40** `ssh pgx` alias added on Windows and in WSL. WSL2 can now reach the machine directly;
  Windows needed `HostKeyAlias` because `known_hosts` only held the IP. See [ssh access](runbooks/ssh-access.md).
- **22:44** External SSD detected (ext4, 1.8 TB) but not mounted; user-level `udisksctl` mount was
  refused by polkit, so the mount was done with sudo and persisted in fstab. See [external SSD](runbooks/external-ssd.md).
- **22:52** SSD held an **x86_64** Isaac Sim 5.1.0-rc.19 build (17 GB) — unusable on aarch64
  ([lesson](lessons/x86-build-on-arm.md)). It was deleted; the user had wanted it archived instead
  ([lesson](lessons/archive-before-delete.md)).
- **22:53** All caches symlinked to `/mnt/ssd/cache`; uv installed; Isaac Lab cloned at `v3.0.0-EA`.
  See [decision](decisions/caches-on-ssd.md).
- **22:56** Confirmed Isaac Sim 6.1 and 6.2 ship **aarch64 wheels** on pypi.nvidia.com, so no source
  build is needed ([decision](decisions/pip-wheels-over-source-build.md)).
- **22:57–23:17** `uv sync --extra isaacsim`: 438 resolved, 253 installed, 20 min (19.5 min of it
  downloading, one 4.7 GB extscache wheel at ~3 MB/s).
- **23:20** First run failed on missing `LD_PRELOAD` libgomp, second on `--headless` no longer
  existing ([lesson](lessons/isaaclab3-cli-and-libgomp.md)).
- **23:27** Cartpole-Direct, PhysX, rsl_rl, 20 iterations: passes, reward −0.11 → 1.67.
- **23:28** `~/.nv` (CUDA ComputeCache) moved to the SSD too.

## 2026-10-19

- **00:00** Researched Cosmos on DGX Spark ([research](research/cosmos-on-spark.md)).
- **00:20** Cosmos3-Nano weights (33 GB, 14 min) and a diffusers venv set up on the SSD.
- **00:47** First Cosmos3-Nano run, 480×832×33f: 139 s, 37.7 GB peak.
- **00:55–01:41** 720p runs at 33, 93 and 189 frames: 268 s, 791 s, 1963 s; peak 45.1 GB.
  See [Cosmos3-Nano runbook](runbooks/cosmos3-nano.md).
- **02:30** This repository created.
- **11:10** VLA stack: Isaac-GR00T (N1.7, `dac54b3`) and LeRobot (`146d8474`) cloned to `/mnt/ssd/vla`.
  GR00T has an official DGX Spark installer with prebuilt flash-attn/torchcodec wheels; its non-sudo part
  ran as-is, the apt part went into `setup-sudo-vla.sh`. See [GR00T + LeRobot runbook](runbooks/gr00t-lerobot.md).
- **11:15–11:30** GR00T venv (torch 2.10, CUDA 13.0) and LeRobot venv (torch 2.11+cu130) installed in
  parallel; `Cosmos-Reason2-2B` (gated), `GR00T-N1.7-3B` and the LIBERO checkpoint downloaded.
- **11:32** LIBERO checkpoint arrived without `config.json`; gvm's `cd` broke the env scripts
  ([lesson](lessons/gvm-cd-and-hf-include.md)).
- **11:33** GR00T N1.7 LIBERO PyTorch inference on GB10: 139.7 ms/step, open-loop MSE 0.00168.
- **11:40** TensorRT pipeline on the LIBERO checkpoint: verify cosine 0.999988; eager 130.1 ms →
  compile 108.6 → TRT 96.0 → TRT + optimized profile 88.7 ms (NVIDIA's Spark table: 200.8 / 183.1 / 116.6).
- **11:45** `izuluaga/finish_sandwich` (SO-101, 80 episodes) converted to LeRobot v2; 30-step probe:
  ~3 s/step at batch 32, 82 GB peak.
- **11:50–13:22** GR00T N1.7 fine-tune, 2,000 steps, 91.7 min, loss 1.14 → 0.051. Open-loop MSE
  30.9 (ckpt 1000) → 20.4 (ckpt 2000). TRT on the fine-tuned checkpoint: 140.0 → 99.3 ms.
  See [runbook §4](runbooks/gr00t-lerobot.md).
