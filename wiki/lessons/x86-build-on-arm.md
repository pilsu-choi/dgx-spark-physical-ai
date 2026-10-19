---
type: Lesson
title: An x86_64 Isaac Sim build is useless on aarch64
description: The SSD carried an x86_64 Isaac Sim 5.1 build that could not run on the Arm machine.
tags: [aarch64, isaac-sim, lesson]
timestamp: 2026-10-19T02:30:00Z
---

# An x86_64 Isaac Sim build is useless on aarch64

The external SSD came with `isaac-sim/` (17 GB), `VERSION` = `5.1.0-rc.19+release.26219.9c81211b.gl`.
`file` showed what it really was:

```
kit/kit:              ELF 64-bit LSB pie executable, x86-64, ... /lib64/ld-linux-x86-64.so.2
kit/python/bin/python3: ELF 64-bit LSB executable, x86-64
*.so:                 ...cpython-311-x86_64-linux-gnu.so
```

Every binary, the bundled Python and all extension `.so` files are x86-64, so none of it can run on
GB10's Arm cores. Moving an Isaac Sim install to a DGX Spark always means reinstalling. Only assets
(USD files, your own scripts) carry over.

**Check first:** `file <install>/kit/kit` before deciding whether an existing install can be reused.
