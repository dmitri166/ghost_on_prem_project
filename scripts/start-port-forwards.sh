#!/bin/bash

# Ghost Platform Port Forwarding Script for WSL
# This script sets up all necessary port forwards for browser access

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Port configuration
declare -A SERVICES=(
    ["ArgoCD"]="8080:8080:argocd:argocd-server"
    ["Grafana"]="3000:3000:monitoring:kube-prometheus-stack-grafana"
    ["Prometheus"]="9090:9090:monitoring:kube-prometheus-stack-prometheus"
    ["AlertManager"]="9093:9093:monitoring:kube-prometheus-stack-alertmanager"
    ["Ghost-Dev"]="2368:2368:ghost-dev:ghost-dev"
    ["Ghost-Staging"]="2369:2368:ghost-staging:ghost-staging"
    ["Ghost-Prod"]="2370:2368:ghost-prod:ghost-prod"
    ["Loki"]="3101:3100:logging:loki"
)

# Function to check if port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to kill existing port forward
kill_port_forward() {
    local local_port=$1
    local pids=$(lsof -ti:$local_port 2>/dev/null || true)
    if [ ! -z "$pids" ]; then
        echo -e "${YELLOW}Killing existing processes on port $local_port...${NC}"
        kill -9 $pids 2>/dev/null || true
        sleep 2
    fi
}

# Function to start port forward
start_port_forward() {
    local name=$1
    local ports=$2
    local namespace=$3
    local service=$4
    
    IFS=':' read -r local_port remote_port <<< "${ports%:*}"
    
    echo -e "${BLUE}Setting up $name on localhost:$local_port...${NC}"
    
    # Check if port is already in use
    if check_port $local_port; then
        echo -e "${YELLOW}Port $local_port is already in use. Attempting to free it...${NC}"
        kill_port_forward $local_port
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

# Function to check Kubernetes connection
check_k8s_connection() {
    echo -e "${BLUE}Checking Kubernetes connection...${NC}"
    if ! kubectl cluster-info >/dev/null 2>&1; then
        echo -e "${RED}✗ Cannot connect to Kubernetes cluster${NC}"
        echo "Please check your kubeconfig and cluster connectivity"
        exit 1
    fi
    echo -e "${GREEN}✓ Kubernetes connection OK${NC}"
}

# Function to display summary
display_summary() {
    echo -e "\n${GREEN}=== Ghost Platform Port Forwarding Summary ===${NC}"
    echo -e "${BLUE}All services are now accessible via your browser:${NC}\n"
    
    echo -e "${YELLOW}🎯 Essential Services (Daily Use):${NC}"
    echo "  • Argo CD:       http://localhost:8080"
    echo "  • Grafana:       http://localhost:3000"
    echo "  • Ghost Dev:     http://localhost:2368"
    echo ""
    
    echo -e "${YELLOW}🔧 Additional Services:${NC}"
    echo "  • Ghost Staging: http://localhost:2369"
    echo "  • Ghost Prod:    http://localhost:2370"
    echo "  • Prometheus:    http://localhost:9090"
    echo "  • AlertManager: http://localhost:9093"
    echo "  • Loki API:      http://localhost:3101"
    echo ""
    
    echo -e "${YELLOW}📋 Default Credentials:${NC}"
    echo "  • Argo CD:       admin (get password with: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
    echo "  • Grafana:       admin / prom-operator"
    echo ""
    
    echo -e "${GREEN}To stop all port forwards, run: ./stop-port-forwards.sh${NC}"
}

# Main execution
main() {
    echo -e "${GREEN}=== Ghost Platform Port Forwarding Setup ===${NC}"
    
    # Check prerequisites
    check_k8s_connection
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}✗ kubectl is not installed or not in PATH${NC}"
        exit 1
    fi
    
    echo -e "\n${BLUE}Starting port forwards...${NC}"
    
    # Start all port forwards
    for service in "${!SERVICES[@]}"; do
        config="${SERVICES[$service]}"
        IFS=':' read -r local_port remote_port namespace service_name <<< "$config"
        start_port_forward "$service" "$local_port:$remote_port" "$namespace" "$service_name"
    done
    
    # Wait a moment for all services to start
    sleep 5
    
    # Display summary
    display_summary
}

# Handle script interruption
trap 'echo -e "\n${YELLOW}Stopping all port forwards...${NC}"; ./stop-port-forwards.sh; exit 0' INT

# Run main function
main "$@"
