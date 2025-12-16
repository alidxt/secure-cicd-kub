#!/usr/bin/env bash
set -euo pipefail
CLUSTER_NAME="${CLUSTER_NAME:-secure-ci}"
echo "Creating kind cluster: $CLUSTER_NAME (if not exists)..."
if ! command -v kind >/dev/null 2>&1; then
  echo "ERROR: kind not found. Install kind first."
  exit 2
fi
if kind get clusters | grep -q "^$CLUSTER_NAME\$"; then
  echo "Cluster $CLUSTER_NAME already exists."
else
  kind create cluster --name "$CLUSTER_NAME"
fi
echo "Done."
