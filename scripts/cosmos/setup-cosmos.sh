#!/usr/bin/env bash
# Cosmos3-Nano via Hugging Face diffusers, venv and weights on the SSD.
# Needs a Hugging Face token in ~/.cache/huggingface/token and the model license accepted.
set -euo pipefail
S=${SSD:-/mnt/ssd}
export PATH=$HOME/.local/bin:$PATH
mkdir -p "$S/cosmos/out" "$S/models" && cd "$S/cosmos"
uv venv --python 3.13 --seed --managed-python
uv pip install --torch-backend=cu130 \
  "diffusers @ git+https://github.com/huggingface/diffusers.git" \
  accelerate av cosmos_guardrail huggingface_hub imageio imageio-ffmpeg torch torchvision transformers
uvx --from "huggingface_hub[cli]" hf download nvidia/Cosmos3-Nano --local-dir "$S/models/Cosmos3-Nano"
