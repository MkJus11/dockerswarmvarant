#!/usr/bin/env bash
set -euo pipefail

MASTER_IP="${1:-192.168.56.10}"
LOCAL_IP="${2:-}"
JOIN_SCRIPT="/vagrant/worker-join.sh"

if docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null | grep -q "^active$"; then
  echo "Este nó já faz parte de um cluster Swarm."
  exit 0
fi

echo "A aguardar o script de adesão do master ($MASTER_IP)..."
for i in $(seq 1 60); do
  if [ -f "$JOIN_SCRIPT" ] && timeout 2 bash -c "</dev/tcp/${MASTER_IP}/2377" 2>/dev/null; then
    break
  fi
  sleep 2
done

if [ ! -f "$JOIN_SCRIPT" ]; then
  echo "Erro: $JOIN_SCRIPT não foi encontrado a tempo." >&2
  exit 1
fi

if [ -n "$LOCAL_IP" ]; then
  TOKEN=$(sed -n 's/.*--token "\([^"]*\)".*/\1/p' "$JOIN_SCRIPT")
  docker swarm join --advertise-addr "$LOCAL_IP" --token "$TOKEN" "${MASTER_IP}:2377"
else
  bash "$JOIN_SCRIPT"
fi

echo "Nó adicionado ao cluster Swarm como worker."
