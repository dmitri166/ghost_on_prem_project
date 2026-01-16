# 🚀 Ghost Blogging Platform with GitOps

## 📋 Overview

This repository implements a **production-ready Ghost blogging platform** with comprehensive **GitOps, CI/CD, monitoring, security, and autoscaling** strategies optimized for **k3d + WSL + Docker Desktop** environments.

## 🏗️ Architecture

### **Ghost Platform Stack**
```
┌─────────────────┬─────────────────┬─────────────────┐
│   Application   │   Platform      │   Infrastructure│
├─────────────────┼─────────────────┼─────────────────┤
│ Ghost CMS       │   ArgoCD        │      k3d        │
│ Node.js         │ KEDA Autoscaling│      Terraform  │
│ OpenTelemetry   │   Prometheus    │   Docker Desktop│
│ Health Checks   │   Grafana       │      WSL2       │
│ Security Scan   │   Tempo         │                 │
└─────────────────┴─────────────────┴─────────────────┘
```

## 🎯 Platform Features

### **1. Multi-Environment GitOps**
- ✅ **Dev/Staging/Prod** - Environment-specific deployments
- ✅ **Automated sync** - ArgoCD GitOps automation
- ✅ **Helm charts** - Standardized deployment
- ✅ **ApplicationSets** - Multi-environment generation

### **2. KEDA Autoscaling**
- ✅ **HTTP-based scaling** - Request-driven autoscaling
- ✅ **CPU/Memory scaling** - Resource-based scaling
- ✅ **Multi-metric** - Combined scaling strategies
- ✅ **Environment-specific** - Different scaling per env

### **3. Comprehensive Monitoring**
- ✅ **Distributed tracing** - Tempo integration
- ✅ **Prometheus metrics** - Ghost performance metrics
- ✅ **Grafana dashboards** - Visual insights
- ✅ **Health monitoring** - Application health checks

### **4. Production Security**
- ✅ **PodSecurityContext** - Non-root containers
- ✅ **Network policies** - Secure communication
- ✅ **TLS termination** - HTTPS support
- ✅ **Secrets management** - Kubernetes secrets

### **5. Production Readiness**
- ✅ **Resource limits** - CPU/Memory constraints
- ✅ **Health checks** - Readiness/liveness probes
- ✅ **Graceful shutdown** - Zero-downtime deployments
- ✅ **Backup strategy** - Data persistence
- ✅ **Observability** - Full stack tracing

## 🚀 Quick Start

### **Prerequisites**
```bash
# Tools required
- Docker Desktop (running)
- WSL2 (enabled)
- k3d (installed)
- Terraform (installed)
- kubectl (installed)
```

### **Deployment Steps**
```bash
# 1. Clone and setup
git clone https://github.com/dmitri166/ghost_on_prem_project.git
cd ghost_on_prem_project

# 2. Deploy infrastructure
cd infrastructure/terraform
terraform init
terraform apply -auto-approve

# 3. Setup kubeconfig
export KUBECONFIG="$(pwd)/k3d-config"

# 4. Deploy Ghost platform
cd ../../
kubectl apply -f platform/argocd/

# 5. Monitor deployment
kubectl get applications -n argocd
```

## 📊 Access URLs

### **Ghost Platform**
```bash
# Ghost Applications (with port forwarding)
Ghost Dev:      http://localhost:2368
Ghost Staging:  http://localhost:2369
Ghost Prod:     http://localhost:2370

# Ghost Admin
Admin Dev:      http://localhost:2368/ghost
Admin Staging:  http://localhost:2369/ghost
Admin Prod:     http://localhost:2370/ghost

# GitOps & Monitoring
ArgoCD:         http://localhost:8080
Prometheus:     http://localhost:9090
Grafana:        http://localhost:3000
Tempo:          http://localhost:3100
```

### **Port Forwarding Commands**
```bash
# Ghost Dev
kubectl port-forward -n ghost svc/ghost-dev-ghost 2368:2368

# Ghost Staging
kubectl port-forward -n ghost svc/ghost-staging-ghost 2369:2368

# Ghost Prod
kubectl port-forward -n ghost svc/ghost-prod-ghost 2370:2368

# ArgoCD (try different ports)
kubectl port-forward -n argocd svc/argocd-server 8080:80
kubectl port-forward -n argocd svc/argocd-server 8443:443

# Prometheus
kubectl port-forward -n monitoring svc/prometheus-server 9090:9090

# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

### **Troubleshooting Port Forwarding**
```bash
# Check service ports first
kubectl get svc -n argocd
kubectl get svc -n ghost
kubectl get svc -n monitoring

# Check if services exist
kubectl get svc -n argocd -o wide

# Alternative: Use NodePort if available
kubectl get svc -n argocd -o yaml | grep -i port
```

## 🔧 Platform Components

### **Ghost Application**
```yaml
# Ghost CMS deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ghost
  namespace: ghost
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: ghost
        image: ghost:5.75.1
        ports:
        - containerPort: 2368
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 1Gi
```

### **KEDA Autoscaling**
```yaml
# HTTP-based autoscaling
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: ghost-http-scaler
spec:
  scaleTargetRef:
    name: ghost
  minReplicaCount: 3
  maxReplicaCount: 10
  triggers:
  - type: http
    metadata:
      targetAverageLatency: "100"
      scalePeriod: "60"
```
## 📁 Project Structure

```
ghost_on_prem_project/
├── 📁 infrastructure/
│   └── 📁 terraform/
│       ├── 📁 modules/
│       │   ├── 📁 k3d-cluster/
│       │   ├── 📁 argocd/
│       │   ├── 📁 kedacore/
│       │   └── 📁 monitoring/
│       └── 📄 main.tf
├── 📁 platform/
│   └── 📁 argocd/
│       ├── 📁 applicationsets/
│       ├── 📁 applications/
│       └── 📄 kustomization.yaml
├── 📁 applications/
│   └── 📁 ghost-app/
│       ├── 📁 helm/
│       │   ├── 📁 templates/
│       │   ├── 📄 values.yaml
│       │   ├── 📄 values-dev.yaml
│       │   ├── 📄 values-staging.yaml
│       │   └── 📄 values-prod.yaml
│       └── 📁 source/
├── 📁 scripts/
│   └── 📄 deploy.sh
└── 📄 README.md
```

## 🔧 Configuration

### **Environment Variables**
```bash
# Ghost Configuration
GHOST_URL="http://ghost-dev.local"
GHOST_ADMIN_URL="http://ghost-dev.local/ghost"

# ArgoCD Configuration
ARGOCD_PASSWORD="your-secure-password"

# Docker Registry
REGISTRY_URL="docker.io/dmitrik2026/ghost-app"
```

### **Terraform Variables**
```hcl
# infrastructure/terraform/terraform.tfvars
cluster_name = "ghost-k3d"
environment = "dev"
admin_password = "your-secure-password"
```

## 🚀 Operations

### **Monitoring Ghost**
```bash
# Check Ghost pods
kubectl get pods -n ghost

# Check Ghost services
kubectl get services -n ghost

# View Ghost logs
kubectl logs -n ghost deployment/ghost

# Access Ghost locally
kubectl port-forward -n ghost svc/ghost-dev-ghost 2368:2368
```

### **ArgoCD Management**
```bash
# List applications
kubectl get applications -n argocd

# Sync specific application
kubectl patch application ghost-dev -n argocd -p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}' --type=merge

# Check ApplicationSet status
kubectl describe applicationset ghost-multi-env -n argocd
```

### **KEDA Autoscaling**
```bash
# Check ScaledObjects
kubectl get scaledobjects -n ghost

# Check HPA status
kubectl get hpa -n ghost

# View scaling events
kubectl get events -n ghost --field-selector reason=SuccessfulRescale
```

## 🔍 Troubleshooting

### **Common Issues**
1. **Ghost not accessible** - Check ingress and port forwarding
2. **ArgoCD sync issues** - Verify GitHub repository access
3. **KEDA not scaling** - Check metrics and triggers
4. **Pods not starting** - Check resource limits and security context

### **Debug Commands**
```bash
# Check cluster status
kubectl cluster-info

# Check all resources
kubectl get all -n ghost

# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-server

# Check KEDA logs
kubectl logs -n keda deployment/keda-operator
```

## 📚 Documentation

- [Ghost CMS Documentation](https://ghost.org/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [KEDA Documentation](https://keda.sh/docs/)
- [k3d Documentation](https://k3d.io/)

---

**🎯 This Ghost platform is production-ready with enterprise-grade GitOps, monitoring, and autoscaling capabilities!**
