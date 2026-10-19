#!/usr/bin/env python3
# Text-to-video benchmark for Cosmos3-Nano. Loads the model once, then runs each config.
# Usage: .venv/bin/python t2v_multi.py 480,832,33,35 720,1280,189,35   (H,W,frames,steps)
import json, sys, time, torch
from diffusers import Cosmos3OmniPipeline
from diffusers.schedulers.scheduling_unipc_multistep import UniPCMultistepScheduler
from diffusers.utils import export_to_video

M = "/mnt/ssd/models/Cosmos3-Nano"
# args: H,W,F,STEPS ...
configs = [tuple(int(x) for x in a.split(",")) for a in sys.argv[1:]]

t0 = time.time()
pipe = Cosmos3OmniPipeline.from_pretrained(M, torch_dtype=torch.bfloat16, device_map="cuda", enable_safety_checker=False)
pipe.scheduler = UniPCMultistepScheduler.from_config(pipe.scheduler.config, flow_shift=10.0)
print(f"LOAD {time.time()-t0:.1f}s  alloc={torch.cuda.memory_allocated()/1e9:.1f}GB", flush=True)

prompt = json.load(open(f"{M}/assets/example_t2v_prompt.json"))
neg = json.load(open(f"{M}/assets/negative_prompt.json"))
for H, W, F, STEPS in configs:
    torch.cuda.reset_peak_memory_stats()
    t1 = time.time()
    r = pipe(prompt=json.dumps(prompt), negative_prompt=json.dumps(neg), num_frames=F, height=H, width=W,
             num_inference_steps=STEPS, guidance_scale=6.0, generator=torch.Generator(device="cuda").manual_seed(123))
    out = f"/mnt/ssd/cosmos/out/t2v_{H}x{W}_{F}f_{STEPS}s.mp4"
    export_to_video(r.video, out, fps=24)
    print(f"RESULT {H}x{W} {F}f {STEPS}steps  GEN {time.time()-t1:.1f}s  peak_alloc={torch.cuda.max_memory_allocated()/1e9:.1f}GB  -> {out}", flush=True)
    del r; torch.cuda.empty_cache()
