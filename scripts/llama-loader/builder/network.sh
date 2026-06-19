# ============================================================
# BUILDER: Network
# Prompts for server port.
# ============================================================
LAST_PORT=$(resolve_default "port" "8080")
echo
read -p "Port [${LAST_PORT}]: " PORT_IN
PORT=${PORT_IN:-$LAST_PORT}
