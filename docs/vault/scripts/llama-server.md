# llama-server.sh

```bash
#!/bin/bash
# Debian — uses local CUDA build (supports sm_61 + sm_86, both GPUs)
# textgen-bundled binary only supports sm_75+ (no Pascal/P40)
LLAMA_BIN="/mnt/workspace/llama.cpp/build/bin"
export LD_LIBRARY_PATH="$LLAMA_BIN:$LD_LIBRARY_PATH"
exec "$LLAMA_BIN/llama-server" "$@"
```
