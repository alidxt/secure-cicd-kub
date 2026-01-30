# secure-cicd-kub (local demo)

Local-only demo: build docker image locally, create a kind cluster, load image into kind, deploy manifests.

Quickstart (inside Codespace):

1. ./scripts/kind-setup.sh
2. ./scripts/deploy-local.sh
3. kubectl -n secure-app get pods,svc
4. kubectl -n secure-app port-forward svc/secure-app 8080:80
5. curl http://127.0.0.1:8080/

