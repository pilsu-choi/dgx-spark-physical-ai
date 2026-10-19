---
type: Decision
title: Isaac Lab v3.0.0-EA with Isaac Sim 6.1
description: Why the early-access 3.0 line was chosen over Isaac Lab 2.3.x.
tags: [isaac-lab, version, decision]
timestamp: 2026-10-19T02:30:00Z
---

# Isaac Lab v3.0.0-EA with Isaac Sim 6.1

**Decision:** use tag `v3.0.0-EA` (2026-09-16), the newest release, which requires Isaac Sim 6.1
and Python 3.12.

**Why:**
- The user asked for a fresh install of the latest versions.
- The 3.0 line ships PyTorch with CUDA 13 wheels for aarch64 and updated DGX Spark install docs
  (since 3.0.0-beta2). Isaac Lab 2.3.x targets Isaac Sim 5.1.
- Isaac Lab 3.0 general availability is targeted for late October 2026; moving from EA to GA should be
  a tag change plus `uv sync`.

**Trade-off:** EA means a new Hydra-based CLI and possible breaking changes before GA
([lesson](../lessons/isaaclab3-cli-and-libgomp.md)). Isaac Sim 6.2 wheels already exist, but
v3.0.0-EA pins 6.1.0.0.
