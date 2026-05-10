# Ollama GPU/CPU Switching Notes for OpenClaw/OpenCode

## Current Setup (GPU enabled)
- Ollama runs with GPU acceleration (default).
- OpenClaw uses Ollama for embedding generation via:
  ```
  openclaw config set agents.defaults.memorySearch.provider ollama
  openclaw config set agents.defaults.memorySearch.model embeddinggemma:latest
  ```
- Embeddings are computed on GPU, which is fast but consumes VRAM.
- Monitor loaded models with: `ollama ps`

## Switching to CPU‑Only Embeddings
When you want to free GPU VRAM for other workloads, switch Ollama to CPU‑only mode.

### 1. Stop the current Ollama server
```bash
# If running as a background job or service:
pkill -f ollama   # or use systemctl if installed as a service
# Verify it's stopped:
ollama ps   # should show no server or error
```

### 2. Restart Ollama with GPU disabled
Set the environment variable `OLLAMA_DISABLE_GPU=1` before starting the server.

#### Temporary (single session):
```bash
OLLAMA_DISABLE_GPU=1 ollama serve &
```

#### Persistent (add to shell profile, e.g., ~/.zshrc or ~/.bashrc):
```bash
export OLLAMA_DISABLE_GPU=1   # place near other exports
# Then restart the shell or run: source ~/.zshrc
# Start Ollama normally after export:
ollama serve &
```

#### Using a systemd service (if applicable):
Edit `/etc/systemd/system/ollama.service` (create if needed) and add under `[Service]`:
```
Environment=OLLAMA_DISABLE_GPU=1
```
Then reload and restart:
```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

### 3. Verify CPU‑only mode
- Check server logs or environment: you should see lines indicating CPU usage.
- GPU utilization (via `nvidia-smi`) should show minimal or no Ollama-related processes.
- `ollama ps` will still list loaded models, but they reside in RAM only.

### 4. OpenClaw configuration remains unchanged
- No need to modify OpenClaw’s `agents.defaults.memorySearch.provider` or `model`.
- OpenClaw continues to send HTTP requests to `http://localhost:11434`; Ollama handles the computation on CPU.

## Switching Back to GPU
Simply omit (or set to `0`) the `OLLAMA_DISABLE_GPU` variable and restart Ollama:
```bash
unset OLLAMA_DISABLE_GPU   # or comment out in profile
ollama serve &
```
Then confirm GPU usage returns with `nvidia-smi`.

## Tips to Manage VRAM Usage
- **Limit concurrently loaded models:**  
  `OLLAMA_MAX_LOADED_MODELS=1 ollama serve`  
  Keeps only the most‑recently used model in memory.
- **Limit parallel requests:**  
  `OLLAMA_NUM_PARALLEL=2 ollama serve`  
  Reduces spikes when many embedding requests arrive.
- **Explicit unload when idle:**  
  `ollama stop <model-name>`  
  Forces immediate VRAM release.
- **Monitor:**  
  `watch -n 5 nvidia-smi`  
  `ollama ps`

## References
- Ollama GPU control: https://github.com/ollama/ollama#gpu-usage
- Environment variables: https://github.com/ollama/ollama/blob/main/docs/faq.md#how-do-i-disable-gpu-usage

---
*Last updated: $(date +%Y-%m-%d)*