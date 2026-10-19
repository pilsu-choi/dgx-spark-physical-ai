set -euo pipefail
export PATH=$HOME/.local/bin:$PATH
cd /mnt/ssd/vla/Isaac-GR00T
S=scripts/deployment/spark
export UV_PROJECT_ENVIRONMENT=$PWD/.venv
uv sync --project $S --no-install-project --extra dev
uv pip install --python .venv/bin/python --no-deps -e .
uv pip install --python .venv/bin/python --force-reinstall --no-deps $S/wheels/flash_attn-*.whl $S/wheels/torchcodec-*.whl
echo GROOT_INSTALL_DONE
