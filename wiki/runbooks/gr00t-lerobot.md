---
type: Runbook
title: GR00T N1.7 and LeRobot on DGX Spark
description: Installing Isaac-GR00T (N1.7) and LeRobot side by side on the SSD, the sudo-only steps, and the first measured GR00T inference on GB10.
tags: [vla, gr00t, lerobot, so-101]
timestamp: 2026-10-19T11:40:00Z
---

# GR00T N1.7 and LeRobot on DGX Spark

Goal: a VLA stack for an SO-ARM 101 workflow — collect data with LeRobot, fine-tune and run GR00T.
Both live under `/mnt/ssd/vla`, each in **its own venv**, because their pins conflict
(GR00T: torch 2.10 / transformers 4.57; LeRobot: torch 2.11 / transformers 5.5).

| | Isaac-GR00T | LeRobot |
| --- | --- | --- |
| Path | `/mnt/ssd/vla/Isaac-GR00T` | `/mnt/ssd/vla/lerobot` |
| Commit | `dac54b3` (2026-10-15) | `146d8474` (v0.6.1+143, 2026-10-16) |
| torch | 2.10.0, CUDA 13.0 (Jetson AI Lab sbsa wheel) | 2.11.0+cu130 (download.pytorch.org) |
| Extras | flash-attn 2.8.3, torchcodec 0.10.0a0 (prebuilt in repo), TensorRT 10.16 | `feetech, smolvla, groot, training, dataset, kinematics` |
| Activate | `groot` alias → [env-groot.sh](../../scripts/vla/env-groot.sh) | `lerobot` alias → [env-lerobot.sh](../../scripts/vla/env-lerobot.sh) |

## 1. sudo steps (once)

[scripts/vla/setup-sudo-vla.sh](../../scripts/vla/setup-sudo-vla.sh), run as `sudo bash ~/setup-sudo-vla.sh`:

- `libnvpl-lapack0 libnvpl-blas0` — the Jetson AI Lab torch wheel links against NVPL; without it
  `import torch` fails in the GR00T venv.
- `ffmpeg` — torchcodec video decoding. `python3-dev` — headers for any source builds.
- `usermod -aG dialout` — SO-101's Feetech bus-servo board shows up as `/dev/ttyACM*`.

The CUDA 13.0 dev packages (`cuda-nvcc-13-0` etc.) that GR00T's installer wants were already
present on DGX OS 7.

## 2. GR00T

GR00T ships a Spark-specific installer (`scripts/deployment/spark/install_deps.sh`) with its own
`pyproject.toml`/`uv.lock` and prebuilt aarch64 wheels for flash-attn and torchcodec. The installer
calls `sudo apt-get` inline, so [install_groot.sh](../../scripts/vla/install_groot.sh) runs only its
non-sudo part:

```bash
cd /mnt/ssd/vla/Isaac-GR00T            # cloned with submodules; git lfs pull for demo_data
S=scripts/deployment/spark
UV_PROJECT_ENVIRONMENT=$PWD/.venv uv sync --project $S --no-install-project --extra dev
uv pip install --python .venv/bin/python --no-deps -e .
uv pip install --python .venv/bin/python --force-reinstall --no-deps $S/wheels/*.whl
```

Never use `uv run` at the repo root — it syncs the **dGPU** pyproject into the venv. Activate the
venv and `source scripts/activate_spark.sh` instead (the `groot` alias does both).

### Models

The VLM backbone `nvidia/Cosmos-Reason2-2B` is **gated**: request access on its model page first,
otherwise loading any GR00T checkpoint fails with 403/`GatedRepoError`. Downloaded:
`nvidia/Cosmos-Reason2-2B`, `nvidia/GR00T-N1.7-3B` (HF cache) and
`nvidia/GR00T-N1.7-LIBERO` `libero_10/` into `checkpoints/` (6.5 GB).

### Smoke test (measured, 2026-10-19)

```bash
groot
python scripts/deployment/standalone_inference_script.py \
  --model-path checkpoints/GR00T-N1.7-LIBERO/libero_10 --dataset-path demo_data/libero_demo \
  --embodiment-tag LIBERO_PANDA --traj-ids 0 1 2 --inference-mode pytorch --execution-horizon 8
```

| Metric | Value |
| --- | --- |
| Model load | 17.9 s |
| Inference per step (PyTorch, chunk of 8) | avg 139.7 ms, min 133.7, P90 142.1 |
| Open-loop action MSE / MAE (3 trajs) | 0.00168 / 0.0133 |

Raw output: [docs/logs/gr00t-libero-pytorch-2026-10-19.txt](../../docs/logs/gr00t-libero-pytorch-2026-10-19.txt).
TensorRT (`build_trt_pipeline.py`, `--inference-mode trt_full_pipeline`) is not tried yet.

## 3. LeRobot

[install_lerobot.sh](../../scripts/vla/install_lerobot.sh): torch first from the cu130 index, then
LeRobot with `--no-sources` (its `tool.uv.sources` pin torch to the **cu128** index, which would
replace the cu130 build):

```bash
uv venv --python 3.12 .venv
uv pip install "torch==2.11.*" "torchvision==0.26.*" --index-url https://download.pytorch.org/whl/cu130
uv pip install --no-sources -e ".[feetech,smolvla,groot,training,dataset,kinematics]"
```

Checked: `torch.cuda.is_available()` on GB10, torchcodec 0.11.1 (aarch64 PyPI wheel), and imports of
`GrootPolicy`, `SmolVLAPolicy` and the `so_follower` robot. LeRobot's GR00T policy supports **N1.7
only** (N1.5 was removed). All `lerobot-*` CLIs (`find-port`, `calibrate`, `teleoperate`, `record`,
`train`, `rollout`) are on the venv PATH.

## Next

- Connect SO-101 leader/follower: `lerobot-find-port`, `lerobot-setup-motors`, `lerobot-calibrate`.
- GR00T SO-101 fine-tune: `examples/SO100/README.md` in Isaac-GR00T (LeRobot v3 → v2 conversion,
  `NEW_EMBODIMENT`), or `lerobot-train --policy.type=groot` directly.
- TensorRT engine build on Spark and its latency vs. the PyTorch number above.
