---
type: Runbook
title: Cosmos3-Nano on DGX Spark
description: Installing Cosmos3-Nano with diffusers and the measured text-to-video performance on GB10.
tags: [cosmos, cosmos3, diffusers, benchmark]
timestamp: 2026-10-19T02:30:00Z
---

# Cosmos3-Nano on DGX Spark

[Cosmos3-Nano](https://huggingface.co/nvidia/Cosmos3-Nano) is a 16B omnimodal world model
(Mixture-of-Transformers: an autoregressive tower and a diffusion tower) released 2026-05-31. The
model card lists GB200 and H100 as test hardware and says only BF16 is tested.

## Install

[scripts/cosmos/setup-cosmos.sh](../../scripts/cosmos/setup-cosmos.sh):

1. Accept the license on the Hugging Face model page; put a token in `~/.cache/huggingface/token`
   (mode 600 — on this machine that path is on the SSD).
2. `uv venv --python 3.13` and install diffusers from git, torch with `--torch-backend=cu130`,
   transformers, accelerate, av, imageio(-ffmpeg), cosmos_guardrail.
3. `hf download nvidia/Cosmos3-Nano --local-dir /mnt/ssd/models/Cosmos3-Nano` — 33 GB, 14 min.

Resulting versions: torch 2.14.1+cu130, diffusers 0.41.0.dev0, transformers 5.20.1.

## Run

[scripts/cosmos/t2v_multi.py](../../scripts/cosmos/t2v_multi.py) loads `Cosmos3OmniPipeline` once
(BF16, `device_map="cuda"`, UniPC scheduler with `flow_shift=10.0`) and generates the model card's
example prompt (a robot arm scrubbing a dirty plate) for each `H,W,frames,steps` config.

```bash
cd /mnt/ssd/cosmos
.venv/bin/python t2v_multi.py 480,832,33,35 720,1280,189,35
```

The official diffusers example ran unmodified — no eager-attention or other workaround was needed.

## Measured performance (2026-10-19)

Guidance 6.0, seed 123, 35 steps, safety checker **off**.

| Resolution | Frames (≈ seconds at 24 fps) | Generation time | Peak GPU allocation |
| --- | --- | --- | --- |
| 480×832 | 33 (1.4 s) | 139 s (2 min 19 s) | 37.7 GB |
| 720×1280 | 33 (1.4 s) | 268 s (4 min 28 s) | 44.0 GB |
| 720×1280 | 93 (3.9 s) | 791 s (13 min 11 s) | 44.4 GB |
| 720×1280 | **189 (7.9 s), official default** | **1963 s (32 min 43 s)** | 45.1 GB |

- Model load: 195–217 s from the USB SSD; 32.8 GB allocated after load.
- Peak system memory (all processes): 66 GB of 119 GB. Running Isaac Sim at the same time would be tight.
- During the 189-frame run: about 52 s per step, GPU at 96 %, 81 °C, about 90 W.
- Raw output: [docs/logs/cosmos3-nano-t2v-2026-10-19.txt](../../docs/logs/cosmos3-nano-t2v-2026-10-19.txt).

![frame at 4 s of the 720p 189-frame run](../../docs/images/cosmos3-nano-720p-189f-frame.jpg)

My estimate before running it ("tens of minutes to over an hour per video") was too pessimistic;
see [research](../research/cosmos-on-spark.md).
