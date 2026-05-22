# Hardware Profile — Example (RTX 5090)
#
# INSTRUCTIONS:
#   Copy this file to config/hardware-profile.md and customize for your machine.
#   config/hardware-profile.md is gitignored and will never be committed.
#   video-agent.bat creates this copy automatically on first launch.
#
# This example shows an RTX 5090 configuration.
# Replace the values below with your actual hardware specs.

## GPU

- **Model**: NVIDIA RTX 5090
- **VRAM**: 32GB GDDR7
- **Architecture**: Blackwell
- **Compute**: FP16, BF16, FP8 (native)

## Capabilities at 32GB VRAM

| Workload | Status | Notes |
|----------|--------|-------|
| FLUX.1-dev FP16 | Native | No quantization needed |
| FLUX.1-dev FP8 | Native | ~16GB, leaves room for other models |
| Wan 2.2 14B | Native | Full quality, no compromises |
| Wan 2.2 14B I2V | Native | 720p at 81 frames |
| FramePack | Overkill | Designed for 6GB, runs effortlessly |
| PuLID Flux II | Native | Dual-character generation works |
| InfiniteYou | Native | Both SIM and AES variants |
| AnimateDiff + LoRA | Native | Batch 4x possible |
| SDXL + ControlNet stack | Native | Multiple ControlNets simultaneously |
| LoRA Training (FLUX) | Native | Standard training, no quantization needed |
| LoRA Training (SDXL) | Native | Batch size 2-4 |

## Recommended Launch Flags

```
--highvram --fp8_e4m3fn-unet
```

- `--highvram`: Keep models in VRAM (no offloading needed)
- `--fp8_e4m3fn-unet`: Optional FP8 for FLUX when running parallel models

## Performance Tips

- Enable tiled VAE only for 8K+ upscaling
- Batch 4x 1024x1024 generations in parallel
- Use FP8 quantization for FLUX only when running concurrent workloads
- cuDNN 8800+ recommended for maximum throughput
