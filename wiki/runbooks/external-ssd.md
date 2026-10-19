---
type: Runbook
title: External SSD: mount and cache redirection
description: Mounting the external ext4 SSD persistently and pointing every cache at it.
tags: [ssd, storage, fstab, cache]
timestamp: 2026-10-19T02:30:00Z
---

# External SSD: mount and cache redirection

## Mount

The SSD showed up as `/dev/sda1` (ext4) but was not mounted. A user-level mount was refused:

```
$ udisksctl mount -b /dev/sda1 --no-user-interaction
Error mounting /dev/sda1: GDBus.Error:org.freedesktop.UDisks2.Error.NotAuthorizedCanObtain
```

So it is mounted with sudo and persisted in fstab — [scripts/mount-ssd.sh](../../scripts/mount-ssd.sh):

```
UUID=<uuid> /mnt/ssd ext4 defaults,nofail,x-systemd.device-timeout=10s 0 2
```

`nofail` plus the 10 s device timeout means the machine still boots normally without the SSD.

## Redirect caches

Isaac Sim, Omniverse, uv, pip, warp, Hugging Face and PyTorch all write tens of GB under `$HOME`.
[scripts/link-caches-to-ssd.sh](../../scripts/link-caches-to-ssd.sh) replaces each of these with a
symlink into `/mnt/ssd/cache`:

| Path under `$HOME` | Contents |
| --- | --- |
| `.cache/uv`, `.local/share/uv` | uv download cache, uv-managed Python interpreters |
| `.cache/pip` | pip cache |
| `.cache/ov`, `.local/share/ov`, `.nvidia-omniverse` | Omniverse Kit caches, logs, config |
| `.cache/warp` | NVIDIA Warp kernel cache |
| `.cache/huggingface` | HF hub cache and token |
| `.cache/torch`, `.cache/nvidia`, `.nv` | torch hub, NVIDIA, CUDA JIT ComputeCache |

Symlinks were chosen over environment variables; see [the decision](../decisions/caches-on-ssd.md).

Verified after the Isaac Lab install: `~/.cache` was 14 MB on the internal disk while the SSD held
the whole environment.
