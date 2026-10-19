---
type: Issue
title: Features not supported on DGX Spark
description: Isaac Lab features that are not supported or validated on DGX Spark, what they do, and workarounds.
tags: [isaac-lab, limitations]
timestamp: 2026-10-19T02:30:00Z
---

# Features not supported on DGX Spark

Per the Isaac Lab v3.0.0-EA docs, these are "not currently supported or validated on DGX Spark":

| Feature | What it is | Why / impact | Workaround |
| --- | --- | --- | --- |
| SkillGen (Isaac Lab Mimic) | Turns a few human demonstrations into thousands of synthetic demos for imitation learning | Uses cuRobo, whose CUDA/C++ extensions are not validated on aarch64 | Generate demos on an x86 machine |
| XR teleoperation | Drive the robot with Vision Pro / Quest hand tracking, usually to record demos | CloudXR and `isaacteleop` packages are x86_64 only | Keyboard/spacemouse teleop, or x86 |
| Livestream | WebRTC streaming of the Isaac Sim GUI from a headless server | Not validated | Monitor on the machine with `--viz kit`; `--viz viser` in a browser; NoMachine or VNC |
| Hub Workstation Cache | Local cache service for Omniverse assets | Not validated | Assets still stream from the cloud, first load is slower |
| Cosmos Transfer1 | Sim-to-real video style transfer | Not validated; its successor Transfer 2.5 is also OOM on 128 GB | Run on a large x86 GPU |
| RLinf | Large-scale distributed RL / VLA training framework | Not validated | rsl_rl, skrl, rl_games and sb3 are unaffected |

Plain RL training with Isaac Lab is unaffected.
