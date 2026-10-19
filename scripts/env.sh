# source this before running Isaac Lab:  source /mnt/ssd/isaac/env.sh
export PATH=$HOME/.local/bin:$PATH
# aarch64: Isaac Sim refuses to start unless the system libgomp is loaded first
export LD_PRELOAD=/lib/aarch64-linux-gnu/libgomp.so.1
# accepts the NVIDIA Omniverse / Isaac Sim EULA non-interactively
export OMNI_KIT_ACCEPT_EULA=YES ACCEPT_EULA=Y
cd /mnt/ssd/isaac/IsaacLab
