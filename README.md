# Secure Reactive CI/CD for Kubernetes (DevSecOps & µs Principles)

A cloud-native framework demonstrating a secure, observable, and reactive CI/CD pipeline for Kubernetes microservices. This project integrates DevSecOps security scanning, Policy-as-Code (OPA), and a full Prometheus/Grafana observability stack aligned with µs (microservice simulation) modeling.

---

## 🏗️ Project Architecture

The system is built around five core pillars:

* **Microservice (`src/app`):** Python-based service instrumented with Prometheus client libraries for granular metrics.
* **Kubernetes Deployment (`infra/k8s`):** Kustomize-based manifests for scalable and resilient deployments.
* **CI/CD & Security (GitHub Actions):** Automated pipeline performing linting, vulnerability scanning, and manifest scoring.
* **Observability Stack (`infra/monitoring`):** Full-cycle monitoring using the kube-prometheus-stack.
* **Policy & µs Modeling (`policy/`, `infra/mu`):** OPA policy enforcement and microservice behavior simulation.

---

## 🚀 Quick Start

### 1. Prerequisites
Ensure you have the following installed:
- [Docker](https://www.docker.com/)
- [Kind](https://kind.sigs.k8s.io/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/)

### 2. Start Cluster & Deploy Application
Initialize the Kind cluster and apply the Kubernetes configurations:
```bash
# Setup the cluster
./scripts/kind-setup.sh

# Deploy the application using Kustomize
kubectl apply -k infra/k8s

2. Deploy Monitoring Stack
Install the Prometheus community stack using Helm.

Bash
helm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts)
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml
3. Port Forward Dashboards
Access the Grafana and Prometheus UIs on your local machine.

Bash
# Grafana
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80

# Prometheus
kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090
4. Load Testing
Generate traffic to validate system reactivity and observability.

Bash
hey -n 5000 -c 50 http://localhost:8080
🔐 DevSecOps CI Pipeline
The GitHub Actions pipeline is designed to catch vulnerabilities and misconfigurations early in the development lifecycle. It includes:

Linting: Code quality checks for Python and Dockerfiles.

Kubernetes Manifest Validation: Ensuring YAML schema correctness.

Security Scanning: Using Trivy to detect container image vulnerabilities.

Policy & Manifest Checks: Evaluating security posture with kube-linter and kube-score.

📊 Observability
The integrated Grafana dashboards provide a 360-degree view of the system's health and performance:

Application Metrics: Request rate (RPS) and P95 latency distributions.

Infrastructure Health: CPU and Memory usage per pod.

Reliability: Tracking pod restarts and deployment state.

Alerting: SLO-oriented metrics and proactive alert management.

📚 Documentation
For detailed information on specific modules, please refer to:

/docs: High-level architecture and design notes.

/infra/monitoring: Detailed monitoring configuration.

/policy: Security policy definitions and OPA rules.

/infra/mu: Technical details of the µs simulation model.
