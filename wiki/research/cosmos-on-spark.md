---
type: Research
title: Cosmos models on DGX Spark
description: Community and official information on running Cosmos models on GB10, and how it compared with measurements.
tags: [cosmos, research, gb10]
timestamp: 2026-10-19T02:30:00Z
---

# Cosmos models on DGX Spark

Collected before testing on 2026-10-19, then compared with the measurements.

| Model | Reported on DGX Spark | Source |
| --- | --- | --- |
| Cosmos Reason 2 (8B) | Officially validated for inference with CUDA 13. 18 GB, 21–68 s per answer via transformers with `attn_implementation="eager"`; vLLM server mode reported unavailable (no FlashAttention for sm_121a). | [NVIDIA prerequisites](https://docs.nvidia.com/cosmos/latest/prerequisites.html), [cosmos-reason2](https://github.com/nvidia-cosmos/cosmos-reason2), [Classmethod](https://dev.classmethod.jp/en/articles/dgx-spark-cosmos-world-model/) |
| Cosmos Predict 2.5 2B | Works with `uv sync --extra=cu130`: 27.7 GB, about 30 min per video. | [Classmethod](https://dev.classmethod.jp/en/articles/dgx-spark-cosmos-world-model/) |
| Cosmos Predict 2.5 14B | Froze the system three times; 128 GB judged not enough. | same |
| Cosmos Transfer 2.5 2B | OOM-killed, needs about 65 GB. | same, [cosmos-transfer2.5](https://github.com/nvidia-cosmos/cosmos-transfer2.5) |
| Predict 2.5 install | transformer-engine and flash-attn have no aarch64 wheels. | [cosmos-predict2.5#120](https://github.com/nvidia-cosmos/cosmos-predict2.5/issues/120) |
| Cosmos3-Nano (16B) | Weights about 32–34 GB in BF16. Guides recommend a 96 GB-class GPU. Reported to fit on a Dell Pro Max GB10 (same chip; article not readable). | [runaihome](https://runaihome.com/blog/nvidia-cosmos-3-nano-local-ai-hardware-guide-2026/), [Koenig](https://academy.kspl.tech/blog/nvidia-cosmos-3-tutorial-open-physical-ai-omnimodel), [Medium](https://medium.com/@kabilankb2003/running-nvidia-cosmos3-nano-on-the-dell-pro-max-gb10-a-16b-world-model-on-your-desk-647994bea9a1) |

NVIDIA's prerequisites page still lists Predict 2.5 and Transfer 2.5 as Linux x86-64 only.

## Prediction vs measurement for Cosmos3-Nano

- **Predicted:** fits in memory; tens of minutes to over an hour per video, given GB10's 273 GB/s
  memory bandwidth and Predict 2.5 2B taking about 30 min; might need an eager-attention workaround.
- **Measured:** fits easily, peak 45 GB at the official setting. 2–5 min for short clips, 33 min for
  the full 720p/189-frame default. The stock diffusers pipeline ran without any workaround.
  See [the runbook](../runbooks/cosmos3-nano.md).
