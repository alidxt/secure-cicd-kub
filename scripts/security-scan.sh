#!/usr/bin/env bash
set -e

IMAGE="secure-app:local"
K8S_DIR="infra/k8s"

echo "======================="
echo "🔍 Running Trivy Scan"
echo "======================="
trivy image --severity HIGH,CRITICAL --ignore-unfixed $IMAGE || true

echo
echo "======================="
echo "🔍 Running kube-linter"
echo "======================="
kube-linter lint $K8S_DIR || true

echo
echo "======================="
echo "🔍 Running kube-score"
echo "======================="
kube-score score $K8S_DIR/*.yaml || true

echo
echo "======================="
echo "✅ Security Scan Complete"
echo "======================="
