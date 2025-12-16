#!/usr/bin/env bash
set -euo pipefail
CLUSTER_NAME="secure-ci"
IMAGE_NAME="secure-app:local"
NAMESPACE="secure-app"

echo "Building Docker image: ${IMAGE_NAME}..."
docker build -t ${IMAGE_NAME} .

echo "Ensure kind cluster '${CLUSTER_NAME}' exists..."
if ! kind get clusters | grep -q "^${CLUSTER_NAME}\$"; then
  echo "Cluster not found. Creating..."
  kind create cluster --name "${CLUSTER_NAME}"
fi

echo "Loading image into kind..."
kind load docker-image ${IMAGE_NAME} --name "${CLUSTER_NAME}"

echo "Applying Kubernetes manifests..."
kubectl apply -k infra/k8s

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=secure-app -n "${NAMESPACE}" --timeout=120s || true

echo "Done. Run: kubectl -n ${NAMESPACE} get pods, svc"
