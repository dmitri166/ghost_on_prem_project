# 🚀 Ghost Platform - Complete DevOps Foundation

[![CI/CD Pipeline](https://github.com/dmitri166/ghost_on_prem_project/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/dmitri166/ghost_on_prem_project/actions)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-blue.svg)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-blue.svg)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-blue.svg)](https://argoproj.github.io/argo-cd/)

A comprehensive **DevOps foundation** for Ghost platform deployment with **Infrastructure as Code**, **GitOps**, **Security**, and **CI/CD** automation.

## 🎯 **Architecture Overview**

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitHub Repository                            │    
│  ┌─────────────────────────────────────────────────────┐        │
│  │              CI/CD Pipeline                         │        │
│  │  ┌─────────────┐  ┌─────────────────────┐           │        │
│  │  │   Policy    │  │   Infrastructure    │           │        │
│  │  │ Validation  │  │   Provisioning      │           │        │
│  │  └─────────────┘  └─────────────────────┘           │        │
│  │         │                    │                      │        │
│  │         ▼                    ▼                      │        │
│  │  ┌─────────────┐  ┌─────────────────────┐           │        │
│  │  │   Security   │  │   Self-Hosted      │           │        │
│  │  │   Scans     │  │   Runner            │           │        │
│  │  └─────────────┘  └─────────────────────┘           │        │
│  │         │                    │                      │        │
│  │         ▼                    ▼                      │        │
│  │  ┌─────────────────────────────────────────────┐    │        │
│  │  │           k3d Cluster                       │    │        │
│  │  │  (1 Master + 2 Workers)                     │    │        │
│  │  └─────────────────────────────────────────────┘    │        │
│  │                    │                                │        │
│  │                    ▼                                │        │
│  │  ┌─────────────────────────────────────────────┐    │        │
│  │  │           ArgoCD (GitOps)                   │    │        │
│  │  │    MetalLB + Ingress + Apps                 │    │        │
│  │  └─────────────────────────────────────────────┘    │        │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 **Repository Structure**

```
ghost_on_prem/
├── 🏗️ infrastructure/           # Infrastructure as Code
│   └── terraform/              # Terraform configurations
│       ├── main.tf             # k3d cluster + core services
│       ├── infrastructure.tf     # Kubernetes providers + Helm releases
│       ├── variables.tf        # Input variables
│       ├── outputs.tf         # Output values
│       └── versions.tf        # Provider versions
├── 🚀 applications/             # Application configurations
│   └── ghost-app/            # Ghost blog application
│       ├── helm/              # Helm charts for deployment
│       └── source/            # Application source code
├── 🔄 platform/                 # Platform services (GitOps)
│   └── argocd/               # ArgoCD configurations
│       ├── applications/        # Application manifests
│       └── applicationsets/   # Multi-environment deployments
├── 🛡️ policy/                    # Policy as Code
│   ├── checkov/              # Security scanning rules
│   ├── tfsec/               # Terraform security rules
│   └── opa/                 # Policy enforcement rules
├── 🔄 .github/workflows/         # CI/CD pipelines
│   └── ci-cd.yml            # Complete DevOps pipeline
└── 📚 scripts/                   # Utility scripts
    └── setup-runner*.sh       # Self-hosted runner setup
```

## 🏗️ **Infrastructure Layer**

### **What Terraform Manages**
- ✅ **k3d Cluster**: 1 master + 2 worker nodes in Docker
- ✅ **Core Services**: MetalLB (LoadBalancer) + ArgoCD (GitOps)
- ✅ **Networking**: Custom Docker network, port mappings
- ✅ **Security**: Disabled conflicting services, proper labels

### **What ArgoCD Manages**
- ✅ **Applications**: Ghost blog (dev/staging/prod)
- ✅ **Monitoring**: Prometheus, Grafana, AlertManager
- ✅ **Ingress**: NGINX Ingress Controller
- ✅ **Security**: Sealed Secrets, security policies

## 🔄 **CI/CD Pipeline**

### **Pipeline Stages**
1. **🛡️ Policy Validation**: Checkov, tfsec, OPA scans
2. **🏗️ Infrastructure**: Terraform plan/apply (manual approval)
3. **🔒 Security**: Trivy vulnerability scanning
4. **🧪 Testing**: Application tests with coverage
5. **🐳 Build**: Docker image build and push
6. **🚀 Deploy**: Multi-environment GitOps deployment

### **Security Features**
- ✅ **Manual Approval**: Only `dmitri166` can deploy infrastructure
- ✅ **Self-Hosted Runner**: Local k3d provisioning
- ✅ **Environment Protection**: Separate dev/staging/prod environments
- ✅ **Policy Enforcement**: Security scans before deployment

## 🚀 **Quick Start**

### **Prerequisites**
- Docker Desktop (Windows/Linux)
- k3d CLI
- Terraform 1.5+
- kubectl
- Self-hosted GitHub runner

### **1. Setup Self-Hosted Runner**
```bash
# Clone repository
git clone https://github.com/dmitri166/ghost_on_prem_project.git
cd ghost_on_prem

# Setup runner (automated)
chmod +x scripts/setup-runner-auto.sh
./scripts/setup-runner-auto.sh "your-github-token"

# Or manual setup
./scripts/setup-runner.sh
```

### **2. Configure GitHub Secrets**
Add these secrets to your repository:
- `REPO_TOKEN`: GitHub personal access token
- `DOCKERHUB_USERNAME`: Docker Hub username
- `DOCKERHUB_TOKEN`: Docker Hub access token

### **3. Enable GitHub Actions**
Go to: https://github.com/dmitri166/ghost_on_prem_project/settings/actions
- Enable "Allow all actions" for third-party integrations

### **4. Deploy Infrastructure**
```bash
# Trigger CI/CD pipeline
git commit -m "Initial infrastructure deployment"
git push origin master

# Manual approve terraform-apply in GitHub UI
# Monitor at: https://github.com/dmitri166/ghost_on_prem_project/actions
```

## 🔧 **Development Workflow**

### **Making Changes**
1. **Infrastructure Changes**: Modify `infrastructure/terraform/`
2. **Application Changes**: Modify `applications/ghost-app/`
3. **Platform Changes**: Modify `platform/argocd/`
4. **Policy Changes**: Modify `policy/`

### **Deployment Process**
1. **Push to master**: Triggers CI/CD pipeline
2. **Policy validation**: Security scans run automatically
3. **Manual approval**: You approve infrastructure changes
4. **GitOps sync**: ArgoCD deploys applications
5. **Multi-environment**: dev → staging → production

## 🛡️ **Security Best Practices**

### **Infrastructure Security**
- ✅ **Policy as Code**: Checkov, tfsec, OPA enforcement
- ✅ **Secret Management**: Sealed Secrets for Kubernetes
- ✅ **Network Isolation**: Custom Docker networks
- ✅ **Access Control**: Only owner can deploy infrastructure

### **CI/CD Security**
- ✅ **Manual Approval**: Infrastructure changes require approval
- ✅ **Self-Hosted Runner**: Local execution only
- ✅ **Environment Protection**: Separate deployment environments
- ✅ **Vulnerability Scanning**: Trivy security scans

### **Application Security**
- ✅ **Container Scanning**: Image vulnerability detection
- ✅ **Secret Encryption**: Sealed Secrets in Git
- ✅ **Network Policies**: Kubernetes network restrictions
- ✅ **RBAC**: Role-based access control

## 📊 **Monitoring & Observability**

### **Infrastructure Monitoring**
- ✅ **Prometheus**: Metrics collection
- ✅ **Grafana**: Visualization dashboards
- ✅ **AlertManager**: Alert management
- ✅ **Node Exporter**: System metrics

### **Application Monitoring**
- ✅ **Application Metrics**: Custom application metrics
- ✅ **Log Aggregation**: Centralized logging
- ✅ **Health Checks**: Application health monitoring
- ✅ **Performance**: Response time tracking

## 🔄 **GitOps Workflow**

### **ArgoCD ApplicationSets**
- ✅ **Multi-Environment**: dev/staging/prod deployments
- ✅ **Helm Integration**: Chart-based deployments
- ✅ **Automated Sync**: Git-triggered deployments
- ✅ **Rollback Support**: Git-based rollbacks

### **Deployment Strategy**
- ✅ **Development**: Automatic deployment on push
- ✅ **Staging**: Manual approval required
- ✅ **Production**: Sequential approval chain
- ✅ **Rollback**: Git-based rollback capability

## 🚨 **Troubleshooting**

### **Common Issues**
- **Runner Offline**: Check runner service status
- **Workflow Failures**: Check GitHub Actions settings
- **Terraform Errors**: Validate configuration syntax
- **ArgoCD Sync**: Check Git connectivity

### **Debug Commands**
```bash
# Check runner status
sudo systemctl status github-runner

# Check cluster status
kubectl get nodes
kubectl get pods -A

# Check ArgoCD sync
kubectl get applications -n argocd
```

## 📚 **Documentation**

- [Infrastructure Details](./infrastructure/README.md)
- [Application Guide](./applications/README.md)
- [Platform Services](./platform/README.md)
- [Policy Documentation](./policy/README.md)
- [Runner Setup](./scripts/README.md)

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch
3. Make changes
4. Submit pull request
5. Automated validation runs
6. Manual review and merge

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🎯 **Key Features Summary**

- ✅ **Infrastructure as Code**: Terraform-managed k3d cluster
- ✅ **GitOps**: ArgoCD for application deployment
- ✅ **Security**: Policy validation, vulnerability scanning
- ✅ **CI/CD**: Automated pipeline with manual approvals
- ✅ **Multi-Environment**: dev/staging/prod deployments
- ✅ **Self-Hosted**: Local runner for on-premise deployment
- ✅ **Monitoring**: Prometheus + Grafana stack
- ✅ **Best Practices**: Industry-standard DevOps patterns

**🚀 Ready for production deployment with enterprise-grade security and observability!**
