#!/bin/bash

# Stop Port Forwards Script for Ghost Platform
# This script stops all running port forwards

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Port configuration
PORTS=(8080 3000 9090 9093 2368 2369 2370 3101)

echo -e "${BLUE}=== Stopping Ghost Platform Port Forwards ===${NC}"

# Stop port forwards using PID files
for port in "${PORTS[@]}"; do
    pid_file="/tmp/ghost-port-forward-$port.pid"
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${YELLOW}Stopping port forward on $port (PID: $pid)...${NC}"
            kill "$pid" 2>/dev/null || true
            sleep 1
            kill -9 "$pid" 2>/dev/null || true
        fi
        rm -f "$pid_file"
    fi
done

# Kill any remaining processes on these ports
echo -e "${BLUE}Checking for remaining processes...${NC}"
for port in "${PORTS[@]}"; do
    pids=$(lsof -ti:$port 2>/dev/null || true)
    if [ ! -z "$pids" ]; then
        echo -e "${YELLOW}Killing remaining processes on port $port...${NC}"
        kill -9 $pids 2>/dev/null || true
    fi
done

echo -e "${GREEN}✓ All port forwards stopped${NC}"
