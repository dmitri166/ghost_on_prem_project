#!/bin/bash
# Ghost Platform - Start Self-Hosted GitHub Runner

set -e

# Configuration
WORK_DIRECTORY="${1:-$HOME/github-runners}"
GITHUB_TOKEN="${2:-$GITHUB_TOKEN}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Ghost Platform GitHub Runner...${NC}"

# Check if runner directory exists
if [ ! -d "$WORK_DIRECTORY" ]; then
    echo -e "${RED}❌ Runner directory not found: $WORK_DIRECTORY${NC}"
    echo -e "${YELLOW}💡 Run setup-runner-auto.sh first${NC}"
    exit 1
fi

cd "$WORK_DIRECTORY"

# Check if runner is already configured
if [ ! -f ".runner" ]; then
    echo -e "${RED}❌ Runner not configured${NC}"
    echo -e "${YELLOW}💡 Run setup-runner-auto.sh first${NC}"
    exit 1
fi

# Check if runner is already running
if pgrep -f "run.sh" > /dev/null; then
    echo -e "${YELLOW}⚠️ Runner is already running${NC}"
    echo -e "${CYAN}📊 Runner status:${NC}"
    ps aux | grep "[r]un.sh"
    exit 0
fi

# Start the runner
echo -e "${YELLOW}🚀 Starting runner service...${NC}"
./run.sh &

# Wait a moment for startup
sleep 3

# Check if runner started successfully
if pgrep -f "run.sh" > /dev/null; then
    echo -e "${GREEN}✅ Runner started successfully${NC}"
    echo -e "${CYAN}🌐 Check status: https://github.com/dmitri166/ghost_on_prem_project/settings/actions/runners${NC}"
else
    echo -e "${RED}❌ Failed to start runner${NC}"
    echo -e "${YELLOW}💡 Check logs: tail -f _diag/Runner_*.log${NC}"
    exit 1
fi

# Show runner info
echo -e "${CYAN}📋 Runner Information:${NC}"
echo -e "   📍 Directory: $WORK_DIRECTORY"
echo -e "   🏷️  Name: $(cat .runner | jq -r .agentName 2>/dev/null || echo 'unknown')"
echo -e "   🔄 Status: Running"
echo -e "   📊 Logs: $WORK_DIRECTORY/_diag/Runner_*.log"
