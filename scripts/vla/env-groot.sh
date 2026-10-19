# source /mnt/ssd/vla/env-groot.sh  — GR00T N1.7 venv (Spark wheels). Do NOT use `uv run` at repo root (it syncs the dGPU pyproject).
builtin cd /mnt/ssd/vla/Isaac-GR00T
source /mnt/ssd/vla/Isaac-GR00T/.venv/bin/activate
source scripts/activate_spark.sh >/dev/null
