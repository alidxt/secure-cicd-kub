#!/usr/bin/env bash
set -e

echo "==============================================="
echo " Secure CI/CD Kubernetes Project - Local Setup "
echo " Ubuntu installation (Step 3 - frozen)         "
echo "==============================================="

# ------------------------------------------------
# 1. Basic system check
# ------------------------------------------------
if ! grep -qi ubuntu /etc/os-release; then
  echo "❌ This setup script is intended for Ubuntu only."
  exit 1
fi

echo "✅ Ubuntu detected"

# ------------------------------------------------
# 2. Install base dependencies
# ------------------------------------------------
echo "📦 Installing base dependencies..."
sudo apt update
sudo apt install -y \
  curl \
  git \
  ca-certificates \
  apt-transport-https \
  gnupg \
  lsb-release

# ------------------------------------------------
# 3. Install Docker
# ------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo "🐳 Installing Docker..."
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker $USER
  echo "⚠️  Log out and log back in to activate Docker group"
else
  echo "✅ Docker already installed"
fi

# ------------------------------------------------
# 4. Install kubectl
# ------------------------------------------------
if ! command -v kubectl >/dev/null 2>&1; then
  echo "☸️ Installing kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo "✅ kubectl already installed"
fi

# ------------------------------------------------
# 5. Install kind
# ------------------------------------------------
if ! command -v kind >/dev/null 2>&1; then
  echo "🧩 Installing kind..."
  curl -Lo kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
  chmod +x kind
  sudo mv kind /usr/local/bin/
else
  echo "✅ kind already installed"
fi

# ------------------------------------------------
# 6. Install security tools (Step 2 / Step 3)
# ------------------------------------------------
echo "🔐 Installing security tools..."

# Trivy
if ! command -v trivy >/dev/null 2>&1; then
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
    | sudo sh -s -- -b /usr/local/bin
else
  echo "✅ Trivy already installed"
fi

# kube-linter
if ! command -v kube-linter >/dev/null 2>&1; then
  curl -L https://github.com/stackrox/kube-linter/releases/latest/download/kube-linter-linux.tar.gz \
    | tar xz
  sudo mv kube-linter /usr/local/bin/
else
  echo "✅ kube-linter already installed"
fi

# kube-score (pinned version – important)
if ! command -v kube-score >/dev/null 2>&1; then
  curl -L https://github.com/zegl/kube-score/releases/download/v1.18.0/kube-score_1.18.0_linux_amd64 \
    -o kube-score
  chmod +x kube-score
  sudo mv kube-score /usr/local/bin/
else
  echo "✅ kube-score already installed"
fi

# ------------------------------------------------
# 7. Prepare project state
# ------------------------------------------------
echo "📁 Preparing project state..."
mkdir -p policy infra/mu
touch .image.digest

# ------------------------------------------------
# 8. Bootstrap Kubernetes + initial deploy
# ------------------------------------------------
echo "🚀 Bootstrapping local Kubernetes cluster..."
chmod +x bootstrap.sh
./bootstrap.sh

# ------------------------------------------------
# 9. Build initial image and record state
# ------------------------------------------------
echo "📦 Building application image..."
docker build -t secure-app:local .

echo "🧾 Recording image state..."
chmod +x scripts/update-image-state.sh
./scripts/update-image-state.sh

# ------------------------------------------------
# 10. Final instructions
# ------------------------------------------------
echo "==============================================="
echo "✅ Setup complete (Project frozen at Step 3)"
echo ""
echo "To start reactive µs simulation:"
echo "  ./scripts/mu-simulate.sh"
echo ""
echo "To allow deployment:"
echo "  touch policy/allow-deploy"
echo ""
echo "To block deployment:"
echo "  rm policy/allow-deploy"
echo ""
echo "This environment is now ready for:"
echo "- Internship evaluation"
echo "- Thesis work"
echo "- Step 4 (Observability) design"
echo "==============================================="
