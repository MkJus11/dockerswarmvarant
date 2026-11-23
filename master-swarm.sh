#!/usr/bin/env bash
set -euo pipefail

MASTER_IP="${1:-192.168.56.10}"
JOIN_SCRIPT="/vagrant/worker-join.sh"

# Garante que o script anterior não fica obsoleto se o cluster for recriado
rm -f "$JOIN_SCRIPT"

if ! docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null | grep -q "^active$"; then
  echo "Inicializando Docker Swarm no master ($MASTER_IP)..."
  docker swarm init --advertise-addr "$MASTER_IP"
else
  echo "Docker Swarm já está ativo neste nó."
fi

WORKER_TOKEN=$(docker swarm join-token -q worker)

cat <<EOF > "$JOIN_SCRIPT"
#!/usr/bin/env bash
set -euo pipefail
docker swarm join --token "${WORKER_TOKEN}" "${MASTER_IP}:2377"
EOF

chmod +x "$JOIN_SCRIPT"
echo "Token de worker guardado em $JOIN_SCRIPT."
