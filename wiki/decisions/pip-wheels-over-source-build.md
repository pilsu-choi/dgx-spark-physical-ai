---
type: Decision
title: Pip wheels instead of a source build
description: Isaac Sim 6.1 is installed from aarch64 pip wheels rather than built from source.
tags: [isaac-sim, aarch64, decision]
timestamp: 2026-10-19T02:30:00Z
---

# Pip wheels instead of a source build

**Decision:** install Isaac Sim from the `isaacsim` pip wheels via Isaac Lab's `--extra isaacsim`.

**Why:** most DGX Spark guides (NVIDIA's dgx-spark-playbooks, the Arm learning path) build Isaac Sim
from source with GCC 11. Isaac Lab's v3.0.0-EA install page does not say whether an aarch64 wheel
exists. Checking the index directly answered it:

```
$ curl -s https://pypi.nvidia.com/isaacsim/ | grep -o '[^/"]*aarch64\.whl'
isaacsim-6.1.0.0-cp312-none-manylinux_2_35_aarch64.whl
isaacsim-6.2.0.0-cp312-none-manylinux_2_35_aarch64.whl
```

The same holds for `isaacsim-kernel`, `-app` and `-core`. The wheels avoid a GCC 11 toolchain (the
machine ships GCC 13.3) and a long build, and they upgrade with `uv sync`.

**Trade-off:** you get no `_build/linux-aarch64/release` tree to patch. That has not been needed so far.
