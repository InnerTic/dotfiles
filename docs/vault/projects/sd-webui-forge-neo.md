# SD WebUI Forge Neo

**Source:** `/mnt/workspace/sd-webui-forge-neo/`  
**GPU 0 (RTX 3060 12GB):** Forge SDXL inference, also runs pipeline small models (Gemma MOE, Floppa) when pipeline is active — swapped as needed  
**GPU 1 (Tesla P40 24GB):** VAE offload & upscaling via Forge, also runs pipeline large models (PromptEnhancer, Qwen, Deep Thinker)

Fork of Stable Diffusion WebUI Forge with resource management optimizations. Primary GPU is the 3060; the P40 provides VRAM headroom for VAE decode and high-res upscale during image gen.

## See Also

- [[reinstall-guides/cachyos/forge-neo\|Forge Neo reinstall guide (CachyOS)]]
- [[reinstall-guides/debian/forge-neo\|Forge Neo reinstall guide (Debian)]]
- [[translation-pipeline\|Translation Pipeline]]
- [[prompt-enhancer\|PromptEnhancer 32B]]
