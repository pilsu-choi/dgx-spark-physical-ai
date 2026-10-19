set -euo pipefail
export PATH=$HOME/.local/bin:$PATH
cd /mnt/ssd/vla/lerobot
uv venv --python 3.12 .venv
uv pip install --python .venv/bin/python "torch==2.11.*" "torchvision==0.26.*" --index-url https://download.pytorch.org/whl/cu130
uv pip install --python .venv/bin/python --no-sources -e ".[feetech,smolvla,groot,training,dataset,kinematics]"
.venv/bin/python -c "import torch,lerobot;print('torch',torch.__version__,torch.version.cuda,torch.cuda.is_available(),torch.cuda.get_device_name(0));print('lerobot ok')"
echo LEROBOT_INSTALL_DONE
