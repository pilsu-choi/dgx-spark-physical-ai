---
type: Decision
title: Caches on the SSD through symlinks
description: Why cache directories are symlinked to the SSD instead of configured with environment variables.
tags: [storage, cache, decision]
timestamp: 2026-10-19T02:30:00Z
---

# Caches on the SSD through symlinks

**Decision:** replace each cache directory under `$HOME` with a symlink into `/mnt/ssd/cache`.

**Why:** the goal is that *nothing* large lands on the internal disk. The tools involved (uv, pip,
Omniverse Kit, warp, Hugging Face, torch, the CUDA driver's ComputeCache) each have their own
environment variable, or none. Kit in particular writes to several fixed paths. A symlink works for
every process: SSH sessions, desktop sessions, cron, and child processes Kit spawns. An environment
variable works only where the shell profile was sourced.

**Consequence:** if the SSD is not mounted, the symlinks dangle and these tools fail instead of
silently filling the internal disk. That is the intended behaviour.
