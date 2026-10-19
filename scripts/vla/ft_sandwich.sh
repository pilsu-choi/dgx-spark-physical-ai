source /mnt/ssd/vla/env-groot.sh
D=examples/SO100/finish_sandwich_lerobot/izuluaga/finish_sandwich
MAX_STEPS=2000 SAVE_STEPS=1000 USE_WANDB=0 NUM_GPUS=1 bash examples/finetune.sh \
  --base-model-path nvidia/GR00T-N1.7-3B --dataset-path $D \
  --modality-config-path examples/SO100/so100_config.py --embodiment-tag NEW_EMBODIMENT \
  --output-dir /mnt/ssd/vla/ft/so101_sandwich_2k
echo FT_DONE exit=$?
