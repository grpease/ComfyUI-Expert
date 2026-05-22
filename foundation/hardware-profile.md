# Hardware Profile

This file is the committed fallback template. For machine-specific settings, use
`config/hardware-profile.md` (gitignored). `video-agent.bat` auto-copies
`config/hardware-profile.example.md` → `config/hardware-profile.md` on first launch.

To customize for your GPU:
1. Open `config/hardware-profile.md` (created automatically by the launcher)
2. Replace the example RTX 5090 values with your actual hardware specs
3. The agent reads `config/hardware-profile.md` first; this file is the fallback

## GPU

- **Model**: *(your GPU model)*
- **VRAM**: *(your VRAM)*
- **Architecture**: *(your architecture)*
- **Compute**: *(supported precision modes)*

## VRAM Capabilities

| Workload | Status | Notes |
|----------|--------|-------|
| FLUX.1-dev FP16 | ? | Requires ~23GB |
| FLUX.1-dev FP8 | ? | Requires ~16GB |
| Wan 2.2 14B | ? | Requires ~24GB |
| FramePack | Runs on 6GB+ | VRAM-invariant |
| PuLID Flux II | ? | Requires ~24-40GB |
| InfiniteYou | ? | Requires ~24GB |
| LoRA Training (FLUX) | ? | Requires ~24GB+ |

## Recommended Launch Flags

```
*(your flags, e.g., --highvram --fp8_e4m3fn-unet)*
```

See `config/hardware-profile.example.md` for a fully configured RTX 5090 example.
