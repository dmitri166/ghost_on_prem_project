#!/bin/bash
# Ghost Platform - Self-Hosted GitHub Runner Setup (GUI-based)
# This script guides you through the most reliable setup process

set -e

# Configuration
WORK_DIRECTORY="${1:-$HOME/github-runners}"
REPO_URL="https://github.com/dmitri166/ghost_on_prem_project"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Ghost Platform - Reliable Runner Setup${NC}"
echo -e "${CYAN}This method uses GitHub UI for maximum reliability${NC}"

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

# Install dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
sudo ./bin/installdependencies.sh

echo -e "${GREEN}✅ Dependencies installed${NC}"

# Guide user through GitHub UI registration
echo -e "${BLUE}🎯 Next Steps - GitHub UI Registration:${NC}"
echo -e ""
echo -e "${YELLOW}1. Open this URL in your browser:${NC}"
echo -e "${CYAN}   https://github.com/dmitri166/ghost_on_prem_project/settings/actions/runners${NC}"
echo -e ""
echo -e "${YELLOW}2. Click 'New self-hosted runner' (green button)${NC}"
echo -e ""
echo -e "${YELLOW}3. Choose your configuration:${NC}"
echo -e "   - Runner group: default"
echo -e "   - Name: ghost-runner"
echo -e "   - Labels: self-hosted,linux,x64"
echo -e ""
echo -e "${YELLOW}4. Copy the registration token (starts with A3A...)${NC}"
echo -e ""

# Prompt for registration token
echo -e "${BLUE}🔑 Please enter the registration token from GitHub UI:${NC}"
read -p "Registration token: " REGISTRATION_TOKEN

if [ -z "$REGISTRATION_TOKEN" ]; then
    echo -e "${RED}❌ Registration token is required${NC}"
    exit 1
fi

# Configure runner
echo -e "${YELLOW}⚙️ Configuring runner...${NC}"
./config.sh \
    --url "$REPO_URL" \
    --token "$REGISTRATION_TOKEN" \
    --name "ghost-runner" \
    --runnergroup "default" \
    --work "./_work" \
    --labels "self-hosted,linux,x64" \
    --unattended

echo -e "${GREEN}✅ Runner configured successfully${NC}"

# Install as service
echo -e "${YELLOW}🔧 Installing runner as service...${NC}"
sudo ./svc.sh install

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Runner service installed${NC}"
    echo -e "${YELLOW}🚀 Starting runner service...${NC}"
    sudo ./svc.sh start
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Runner service started successfully${NC}"
    else
        echo -e "${RED}❌ Failed to start runner service${NC}"
        echo -e "${YELLOW}💡 Starting manually...${NC}"
        ./run.sh &
    fi
else
    echo -e "${YELLOW}⚠️ Could not install as service, starting manually...${NC}"
    ./run.sh &
fi

# Wait a moment for startup
sleep 5

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

# Show runner status
echo -e "${YELLOW}📊 Checking runner status...${NC}"
if pgrep -f "run.sh" > /dev/null; then
    echo -e "${GREEN}✅ Runner is running${NC}"
else
    echo -e "${RED}❌ Runner is not running${NC}"
    echo -e "${YELLOW}💡 Start manually: cd $WORK_DIRECTORY && ./run.sh${NC}"
fi

echo -e "${GREEN}🎉 Setup completed!${NC}"
echo -e "${CYAN}📍 Runner location: $WORK_DIRECTORY${NC}"
echo -e "${CYAN}🌐 GitHub UI: https://github.com/dmitri166/ghost_on_prem_project/settings/actions/runners${NC}"
echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "   1. Check runner status in GitHub UI (should show 'Idle')${NC}"
echo -e "   2. Test with: git commit and push to master${NC}"
echo -e "   3. Monitor at: https://github.com/dmitri166/ghost_on_prem_project/actions${NC}"

echo -e "${BLUE}🔧 Useful commands:${NC}"
echo -e "   Check status: ps aux | grep '[r]un.sh'"
echo -e "   View logs: tail -f $WORK_DIRECTORY/_diag/Runner_*.log"
echo -e "   Stop runner: sudo systemctl stop actions.runner.*"
echo -e "   Start runner: cd $WORK_DIRECTORY && ./run.sh"
