#!/usr/bin/env bash
set -e

echo "µs simulator started (local mode)"
echo "Watching .image.digest for changes..."

LAST=""

while true; do
  if [ -f .image.digest ]; then
    CURRENT=$(cat .image.digest)

    if [ "$CURRENT" != "$LAST" ]; then
      echo "[µs] Image change detected"

      if [ ! -f policy/allow-deploy ]; then
        echo "[µs] ❌ Policy blocked deployment"
      else
        echo "[µs] ✅ Policy passed → deploying"
        kubectl apply -k infra/k8s
      fi

      LAST="$CURRENT"
    fi
  fi

  sleep 2
done
