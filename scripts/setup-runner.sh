#!/bin/bash
# Ghost Platform - Self-Hosted GitHub Runner Setup Script
# This script sets up a self-hosted GitHub Actions runner on Linux/WSL

set -e

# Configuration
GITHUB_TOKEN="${1:-$GITHUB_TOKEN}"
RUNNER_NAME="${2:-ghost-runner}"
RUNNER_GROUP="${3:-default}"
WORK_DIRECTORY="${4:-$HOME/github-runners}"
REPO_URL="https://github.com/dmitri166/ghost_on_prem_project"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Setting up Ghost Platform GitHub Runner...${NC}"

# Validate input
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ GitHub token is required!${NC}"
    echo -e "${YELLOW}Usage: $0 <GITHUB_TOKEN> [RUNNER_NAME] [RUNNER_GROUP] [WORK_DIRECTORY]${NC}"
    exit 1
fi

# Create working directory
echo -e "${YELLOW}📁 Creating working directory...${NC}"
mkdir -p "$WORK_DIRECTORY"
cd "$WORK_DIRECTORY"

# Download latest runner
echo -e "${YELLOW}📥 Downloading GitHub Actions Runner...${NC}"
RUNNER_VERSION="2.311.0"
RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

curl -o actions-runner.tar.gz -L "$RUNNER_URL"
tar xzf ./actions-runner.tar.gz
rm actions-runner.tar.gz

echo -e "${GREEN}✅ Runner downloaded and extracted${NC}"

# Configure runner
echo -e "${YELLOW}⚙️ Configuring runner...${NC}"
./config.sh --url "$REPO_URL" --token "$GITHUB_TOKEN" --name "$RUNNER_NAME" --runnergroup "$RUNNER_GROUP" --work "./_work"

echo -e "${GREEN}✅ Runner configured successfully${NC}"

# Install and start as service
echo -e "${YELLOW}🔧 Installing runner as service...${NC}"
sudo ./svc.sh install "$RUNNER_NAME"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Runner service installed${NC}"
    echo -e "${YELLOW}🚀 Starting runner service...${NC}"
    sudo ./svc.sh start
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Runner service started successfully${NC}"
    else
        echo -e "${RED}❌ Failed to start runner service${NC}"
        echo -e "${YELLOW}💡 You can run manually: ./run.sh${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Could not install as service, you can run manually${NC}"
    echo -e "${CYAN}💡 Run: ./run.sh to start the runner${NC}"
fi

# Verify prerequisites
echo -e "${YELLOW}🔍 Verifying prerequisites...${NC}"

# Check Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✅ Docker: $DOCKER_VERSION${NC}"
else
    echo -e "${RED}❌ Docker not found. Please install Docker Desktop${NC}"
fi

# Check k3d
if command -v k3d &> /dev/null; then
    K3D_VERSION=$(k3d --version)
    echo -e "${GREEN}✅ k3d: $K3D_VERSION${NC}"
else
    echo -e "${YELLOW}❌ k3d not found. Installing k3d...${NC}"
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

# Check Terraform
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform --version)
    echo -e "${GREEN}✅ Terraform: $TERRAFORM_VERSION${NC}"
else
    echo -e "${YELLOW}❌ Terraform not found. Installing Terraform...${NC}"
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install -y terraform
fi

# Check kubectl
if command -v kubectl &> /dev/null; then
    KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null || kubectl version --client)
    echo -e "${GREEN}✅ kubectl: $KUBECTL_VERSION${NC}"
else
    echo -e "${YELLOW}❌ kubectl not found. Installing kubectl...${NC}"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

echo -e "${GREEN}🎉 GitHub Runner setup completed!${NC}"
echo -e "${CYAN}📍 Runner location: $WORK_DIRECTORY${NC}"
echo -e "${CYAN}🌐 GitHub UI: https://github.com/dmitri166/ghost_on_prem_project/settings/actions/runners${NC}"
echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "   1. Check runner status in GitHub UI"
echo -e "   2. Update CI/CD workflow to use self-hosted runner"
echo -e "   3. Test with a commit to master branch"

# Show runner status
echo -e "${YELLOW}📊 Runner status:${NC}"
if pgrep -f "run.sh" > /dev/null; then
    echo -e "${GREEN}✅ Runner is running${NC}"
else
    echo -e "${RED}❌ Runner is not running${NC}"
    echo -e "${YELLOW}💡 Start manually: cd $WORK_DIRECTORY && ./run.sh${NC}"
fi
