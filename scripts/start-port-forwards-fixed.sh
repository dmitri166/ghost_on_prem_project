#!/bin/bash

# Quick Fix for Ghost Platform Port Forwarding
# Use this to start currently available services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Ghost Platform Port Forwarding (Quick Fix) ===${NC}"

# Function to start port forward
start_port_forward() {
    local name=$1
    local local_port=$2
    local remote_port=$3
    local namespace=$4
    local service=$5
    
    echo -e "${BLUE}Setting up $name on localhost:$local_port...${NC}"
    
    # Kill any existing processes on this port
    local pids=$(lsof -ti:$local_port 2>/dev/null || true)
    if [ ! -z "$pids" ]; then
        echo -e "${YELLOW}Killing existing processes on port $local_port...${NC}"
        kill -9 $pids 2>/dev/null || true
        sleep 2
    fi
    
    # Start port forward in background
    kubectl port-forward -n $namespace svc/$service $local_port:$remote_port &
    local pid=$!
    
    # Wait a moment and check if it's working
    sleep 3
    if kill -0 $pid 2>/dev/null; then
        echo -e "${GREEN}✓ $name is running on localhost:$local_port (PID: $pid)${NC}"
        echo "$pid" > "/tmp/ghost-port-forward-$local_port.pid"
    else
        echo -e "${RED}✗ Failed to start $name${NC}"
    fi
}

echo -e "${BLUE}Starting available services...${NC}"

# Start ArgoCD
start_port_forward "ArgoCD" "8080" "80" "argocd" "argocd-server"

# Start Ghost applications
start_port_forward "Ghost-Dev" "2368" "2368" "ghost-dev" "ghost-dev"
start_port_forward "Ghost-Staging" "2369" "2368" "ghost-staging" "ghost-staging"
start_port_forward "Ghost-Prod" "2370" "2368" "ghost-prod" "ghost-prod"

# Try to start monitoring services if available
if kubectl get service kube-prometheus-stack-grafana -n monitoring >/dev/null 2>&1; then
    start_port_forward "Grafana" "3000" "3000" "monitoring" "kube-prometheus-stack-grafana"
fi

if kubectl get service kube-prometheus-stack-prometheus -n monitoring >/dev/null 2>&1; then
    start_port_forward "Prometheus" "9090" "9090" "monitoring" "kube-prometheus-stack-prometheus"
fi

if kubectl get service kube-prometheus-stack-alertmanager -n monitoring >/dev/null 2>&1; then
    start_port_forward "AlertManager" "9093" "9093" "monitoring" "kube-prometheus-stack-alertmanager"
fi

if kubectl get service loki -n logging >/dev/null 2>&1; then
    start_port_forward "Loki" "3101" "3100" "logging" "loki"
fi

# Wait a moment for all services to start
sleep 5

echo -e "\n${GREEN}=== Port Forwarding Summary ===${NC}"
echo -e "${BLUE}Check these URLs in your browser:${NC}\n"

echo -e "${YELLOW}🎯 Essential Services:${NC}"
echo "  • Argo CD:       http://localhost:8080"
echo "  • Ghost Dev:     http://localhost:2368"

if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "  • Grafana:       http://localhost:3000"
fi

echo ""
echo -e "${YELLOW}🔧 Additional Services:${NC}"
echo "  • Ghost Staging: http://localhost:2369"
echo "  • Ghost Prod:    http://localhost:2370"

if lsof -Pi :9090 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "  • Prometheus:    http://localhost:9090"
fi

if lsof -Pi :9093 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "  • AlertManager: http://localhost:9093"
fi

if lsof -Pi :3101 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "  • Loki API:      http://localhost:3101"
fi

echo ""
echo -e "${YELLOW}📋 Default Credentials:${NC}"
echo "  • Argo CD:       admin (get password with: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"

if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "  • Grafana:       admin / prom-operator"
fi

echo ""
echo -e "${GREEN}To stop all port forwards, run: ./stop-port-forwards.sh${NC}"
