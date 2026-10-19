---
type: Lesson
title: gvm overrides cd, and hf download treats extra arguments as filenames
description: Two small traps hit while setting up GR00T and LeRobot — env scripts that cd broke under gvm, and a checkpoint downloaded without its config.json.
tags: [lessons, gvm, huggingface, vla]
timestamp: 2026-10-19T11:40:00Z
---

# gvm overrides `cd`, and `hf download` treats extra arguments as filenames

## gvm's `cd` function

gvm (installed for Go) replaces `cd` with a shell function in interactive shells. Inside a sourced
env script run from a non-tty shell (`ssh pgx 'bash -ic ...'`), that function left the shell in
`$HOME`, so the following `source .venv/bin/activate` failed. The env scripts
([env-groot.sh](../../scripts/vla/env-groot.sh), [env-lerobot.sh](../../scripts/vla/env-lerobot.sh),
[env.sh](../../scripts/env.sh)) now use `builtin cd` and absolute paths.

## `hf download repo a b --include ...`

Following the GR00T README, `hf download nvidia/GR00T-N1.7-LIBERO --include "libero_10/config.json" ...`
printed `Ignoring --include since filenames have been explicitly set` and fetched every file except
`config.json`. Loading then failed with `ValueError: Unrecognized model ... Should have a model_type key`.
Fix: download the missing file by name (`hf download nvidia/GR00T-N1.7-LIBERO libero_10/config.json --local-dir ...`)
and check the file list after a filtered download.
