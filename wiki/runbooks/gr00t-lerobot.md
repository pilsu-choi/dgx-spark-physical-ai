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

### TensorRT (measured, 2026-10-19)

```bash
groot
python scripts/deployment/build_trt_pipeline.py \
  --model-path checkpoints/GR00T-N1.7-LIBERO/libero_10 --dataset-path demo_data/libero_demo \
  --embodiment-tag LIBERO_PANDA --output-dir /mnt/ssd/vla/trt/libero10_baseline --flat-e2e
# Thor's optimized execution profile (K/V caching, projection fusion, CUDA graphs) also works on GB10:
#   ... --output-dir /mnt/ssd/vla/trt/libero10_optimized --batch-size 1 --execution-profile optimized
```

Export (7 ONNX files) 1 min, engine build 1.4 min, verify cosine **0.999988 PASS** for both.
Built-in benchmark — complete policy call, action horizon 40, 4 denoising steps, median of 20:

| Mode | GB10 measured | NVIDIA's DGX Spark number |
| --- | --- | --- |
| PyTorch eager | 130.1 ms (7.7 Hz) | 200.8 ms |
| torch.compile (DiT) | 108.6 ms (9.2 Hz) | 183.1 ms |
| TensorRT full pipeline | **96.0 ms (10.4 Hz)** | 116.6 ms |
| TensorRT + optimized profile | **88.7 ms (11.3 Hz)** | — |

`standalone_inference_script.py --inference-mode trt_full_pipeline --trt-engine-path .../engines`
on the same 3 trajectories: 97.4 ms/step (vs 139.7 ms PyTorch), MSE 0.00160 (vs 0.00168) — same
accuracy, 1.43× faster. FP8/NVFP4 quantization (needs ModelOpt) not tried. Raw output:
[docs/logs/gr00t-trt-2026-10-19.txt](../../docs/logs/gr00t-trt-2026-10-19.txt).
Engines are tied to the checkpoint and GPU: rebuild them for every fine-tuned checkpoint.

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

## 4. GR00T fine-tune on a public SO-101 dataset (measured, 2026-10-19)

Dataset: [izuluaga/finish_sandwich](https://huggingface.co/datasets/izuluaga/finish_sandwich) —
`so101_follower`, 80 episodes, 70,277 frames at 30 fps, front + wrist cameras, 6-D state/action.
Following `examples/SO100/README.md`:

```bash
groot
uv run --project scripts/lerobot_conversion python scripts/lerobot_conversion/convert_v3_to_v2.py \
  --repo-id izuluaga/finish_sandwich --root examples/SO100/finish_sandwich_lerobot   # its own project: uv run is fine here
cp examples/SO100/modality.json examples/SO100/finish_sandwich_lerobot/izuluaga/finish_sandwich/meta/
nohup bash /mnt/ssd/vla/ft_sandwich.sh > /mnt/ssd/vla/ft_sandwich.log 2>&1 &
```

[ft_sandwich.sh](../../scripts/vla/ft_sandwich.sh) runs `examples/finetune.sh` from `nvidia/GR00T-N1.7-3B`
with `NEW_EMBODIMENT`, `examples/SO100/so100_config.py`, batch 32, `MAX_STEPS=2000`, `USE_WANDB=0`
(the official default is 10,000 steps).

| | Value |
| --- | --- |
| Step time (steady state) | ~2.75 s/step at batch 32 (11.6 samples/s) |
| 2,000 steps | 91.7 min; loss 1.14 → 0.051 |
| Peak system memory (unified) | 82 GB of 119 GB |
| 10,000 steps (extrapolated) | ~7.6 h |

Open-loop eval (`gr00t/eval/open_loop_eval.py`, `--execution-horizon 16 --steps 400`, trajectories
0, 10, 40 — all **in the training set**, so this checks fitting, not generalization). Units are
joint degrees, gripper 0–100:

| Checkpoint | Average MSE | Average MAE |
| --- | --- | --- |
| 1000 | 30.9 | 3.57 |
| 2000 | 20.4 | 2.81 |

Error falls with steps, the signal GR00T's
[finetune guide](https://github.com/NVIDIA/Isaac-GR00T/blob/main/getting_started/finetune_new_embodiment.md)
says to look for, and the trajectory-0 plot tracks the ground truth on all six joints, including the
gripper open/close timing:
[gr00t-so101-sandwich-2k-traj0.jpeg](../../docs/logs/gr00t-so101-sandwich-2k-traj0.jpeg).
`open_loop_eval.py` writes its plots to `/tmp/open_loop_eval/` and overwrites them on the next run.

TRT on the fine-tuned checkpoint (`--embodiment-tag NEW_EMBODIMENT`, optimized profile): cosine
1.000000 PASS; eager 140.0 ms → compile 120.5 ms → **TensorRT 99.3 ms**.
Raw output: [docs/logs/gr00t-so101-finetune-2026-10-19.txt](../../docs/logs/gr00t-so101-finetune-2026-10-19.txt).

## Next

- Connect SO-101 leader/follower: `lerobot-find-port`, `lerobot-setup-motors`, `lerobot-calibrate`.
- Closed loop on the real arm: `gr00t/eval/run_gr00t_server.py` + `gr00t/eval/real_robot/SO100/eval_so100.py`.
- Full 10,000-step run with a held-out episode split; `lerobot-train --policy.type=groot` as the
  alternative training path.
- FP8 quantization of the TRT engines (needs ModelOpt).
