#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script: builds app image locally, creates kind cluster, loads image, deploys k8s manifests

REPO_ROOT="$(pwd)"
CLUSTER_NAME="secure-ci"
IMAGE_NAME="secure-app:local"
NAMESPACE="secure-app"

echo "=== 1) Creating project files..."

mkdir -p src/app infra/k8s infra/mu opa .github/workflows scripts docs

# Dockerfile
cat > Dockerfile <<'DOCKER'
# Dockerfile - minimal Python HTTP server
FROM python:3.11-slim

WORKDIR /app
COPY src/app/requirements.txt .
RUN if [ -s requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

COPY src/app/ .

EXPOSE 8080
CMD ["python", "main.py"]
DOCKER

# simple app
cat > src/app/main.py <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer
import os

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type","text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(b"secure-app: hello from Ali's demo\\n")

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8080"))
    server = HTTPServer(("0.0.0.0", port), Handler)
    print(f"Listening on {port}...")
    server.serve_forever()
PY

# requirements (empty to keep image small)
cat > src/app/requirements.txt <<'REQ'
# no runtime dependencies for this demo
REQ

# Kubernetes manifests (image uses local tag secure-app:local)
cat > infra/k8s/namespace.yaml <<'NMS'
apiVersion: v1
kind: Namespace
metadata:
  name: secure-app
NMS

cat > infra/k8s/deployment.yaml <<'DEP'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: secure-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      containers:
      - name: secure-app
        image: secure-app:local
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
        env:
        - name: PORT
          value: "8080"
DEP

cat > infra/k8s/service.yaml <<'SVC'
apiVersion: v1
kind: Service
metadata:
  name: secure-app
  namespace: secure-app
spec:
  selector:
    app: secure-app
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
SVC

cat > infra/k8s/kustomization.yaml <<'KUS'
resources:
- namespace.yaml
- deployment.yaml
- service.yaml
KUS

# µs skeleton
cat > infra/mu/secure-app.mu <<'MU'
# µs IaC skeleton for secure-app (placeholder)
# Add reactive triggers and variables as needed.
resource "kubernetes_namespace" "secure_app" {
  name = "secure-app"
}
MU

# OPA example
cat > opa/policy.rego <<'REGO'
package kubernetes.admission

deny[msg] {
  input.kind.kind == "Pod"
  some i
  container := input.request.object.spec.containers[i]
  not container.securityContext
  msg := sprintf("container %v has no securityContext and may run as root", [container.name])
}
REGO

# GitHub Actions workflow (kept but won't push images when local only)
cat > .github/workflows/ci-cd.yml <<'YML'
name: CI/CD Secure App (local mode)

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Print repo files
      run: ls -R
YML

# scripts
cat > scripts/kind-setup.sh <<'KS'
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
KS
chmod +x scripts/kind-setup.sh

cat > scripts/deploy-local.sh <<'DL'
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
DL
chmod +x scripts/deploy-local.sh

# README
cat > README.md <<'RD'
# secure-cicd-kub (local demo)

Local-only demo: build docker image locally, create a kind cluster, load image into kind, deploy manifests.

Quickstart (inside Codespace):

1. ./scripts/kind-setup.sh
2. ./scripts/deploy-local.sh
3. kubectl -n secure-app get pods,svc
4. kubectl -n secure-app port-forward svc/secure-app 8080:80
5. curl http://127.0.0.1:8080/

RD

echo "=== 2) Files created."

echo "=== 3) Building Docker image (local)..."
docker build -t ${IMAGE_NAME} .

echo "=== 4) Create kind cluster '${CLUSTER_NAME}' (if needed) ..."
if ! command -v kind >/dev/null 2>&1; then
  echo "ERROR: 'kind' not installed. Please install it in the Codespace (pkg manager or curl)."
  echo "Visit: https://kind.sigs.k8s.io/"
  exit 2
fi

if kind get clusters | grep -q "^${CLUSTER_NAME}\$"; then
  echo "kind cluster ${CLUSTER_NAME} already exists - skipping creation."
else
  kind create cluster --name "${CLUSTER_NAME}"
fi

echo "=== 5) Load image into kind ..."
kind load docker-image ${IMAGE_NAME} --name "${CLUSTER_NAME}"

echo "=== 6) Apply k8s manifests ..."
kubectl apply -k infra/k8s

echo "=== 7) Wait for deployment to be ready (120s timeout) ..."
kubectl wait --for=condition=available deployment/secure-app -n ${NAMESPACE} --timeout=120s || true

echo "=== Bootstrap complete ==="
echo
echo "Useful commands:"
echo "  kubectl -n ${NAMESPACE} get pods,svc"
echo "  kubectl -n ${NAMESPACE} port-forward svc/secure-app 8080:80 &"
echo "  curl http://127.0.0.1:8080/"
