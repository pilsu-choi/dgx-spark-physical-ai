---
type: Issue
title: Cosmos3-Nano modes not yet tested
description: Only text-to-video has been run; other Cosmos3-Nano capabilities are untested on this machine.
tags: [cosmos, todo]
timestamp: 2026-10-19T02:30:00Z
---

# Cosmos3-Nano modes not yet tested

Tested: text-to-video only, safety checker off.

Not tested yet:
- image-to-video and video-to-video
- action-conditioned generation and action output (Franka, UR, WidowX and other embodiments)
- the Reasoner tower (text/image/video → text, up to 256K context)
- the guardrail / safety checker (`enable_safety_checker=True` downloads extra models)
- running Cosmos while Isaac Sim is also loaded (66 GB peak + Isaac Sim may not fit comfortably)
- vLLM-Omni / SGLang backends on aarch64
