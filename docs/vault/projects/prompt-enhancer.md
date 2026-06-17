# PromptEnhancer 32B

**Model:** `PromptEnhancer-32B.i1-Q4_K_M.gguf` (~20GB)  
**GPU:** Tesla P40 24GB (port 8081 — briefer role in translation pipeline)  
**Source:** `/home/ken/Downloads/llm_models/PromptEnhancer-32B.i1-Q4_K_M.gguf`

Used as the **Briefer** in the [[translation-pipeline\|Translation Pipeline]]. Extracts characters, locations, relationships, prior events, and Ambiguity Anchors from each chunk. Briefs the Verifier only (not the Translator).

Also usable standalone via `start-server.sh` for ad-hoc prompt enhancement.

## See Also

- [[translation-pipeline\|Translation Pipeline]]
- [[sd-webui-forge-neo\|SD WebUI Forge Neo]] — shares P40 for VAE offload
