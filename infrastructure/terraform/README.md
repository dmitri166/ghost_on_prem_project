# Terraform Infrastructure for Ghost Platform

This directory contains the Terraform configuration for provisioning the k3d cluster and core infrastructure components for the Ghost platform.

## Architecture Overview

### 🏗️ **Infrastructure Provisioning (Terraform)**
- **k3d Cluster**: 1 master + 2 worker nodes
- **Core Services**: MetalLB, ArgoCD
- **Namespaces**: infrastructure, argocd
- **Networking**: Custom network with port mapping

### 🚀 **Application Management (ArgoCD + GitOps)**
- **Ghost Applications**: Managed via ArgoCD ApplicationSets
- **Databases**: MySQL per environment (dev/staging/prod)
- **Monitoring**: Prometheus, Grafana, AlertManager
- **Logging**: Loki stack

### 📦 **Helm Charts**
- **Applications**: `applications/ghost-app/helm/`
- **Infrastructure**: `infrastructure/mysql/helm/`
- **Platform Services**: `platform/manifests/`

## Structure

```
infrastructure/terraform/
├── main.tf              # k3d cluster configuration
├── variables.tf          # Input variables
├── outputs.tf           # Output values
├── versions.tf          # Provider versions
├── infrastructure.tf    # Core infrastructure resources
└── README.md            # This file
```

## Prerequisites

1. **Terraform >= 1.5.0**
2. **Docker** (for k3d containers)
3. **kubectl** (for cluster access)
4. **Helm 3.x** (for local testing)

## Usage

### Initialize Terraform

```bash
cd infrastructure/terraform
terraform init
```

### Plan the infrastructure

```bash
terraform plan
```

### Apply the infrastructure

```bash
terraform apply
```

### Destroy the infrastructure

```bash
terraform destroy
```

## Configuration

### Cluster Configuration

The k3d cluster is configured as:

- **Master Nodes**: 1 (control plane)
- **Worker Nodes**: 2 (workload)
- **k3s Version**: v1.28.3+k3s.1
- **Network**: Custom Docker network
- **Ports**: API (6443), HTTP (80), HTTPS (443)

### Variables

| Variable | Description | Default |
|----------|-------------|----------|
| `cluster_name` | Name of the k3d cluster | `ghost-k3d` |
| `k3s_version` | k3s version to deploy | `v1.28.3+k3s.1` |
| `master_nodes` | Number of master nodes | `1` |
| `worker_nodes` | Number of worker nodes | `2` |
| `cluster_cidr` | CIDR for pod network | `10.42.0.0/16` |
| `service_cidr` | CIDR for service network | `10.43.0.0/16` |

### Outputs

| Output | Description |
|---------|-------------|
| `cluster_name` | The name of the k3d cluster |
| `kube_config_path` | Path to the kubeconfig file |
| `cluster_endpoint` | The Kubernetes API endpoint |
| `cluster_version` | The k3s version |
| `master_nodes` | Number of master nodes |
| `worker_nodes` | Number of worker nodes |
| `total_nodes` | Total number of nodes |

## Infrastructure Components

### 🔄 **ArgoCD**
- **Purpose**: GitOps controller for application deployment
- **Namespace**: `argocd`
- **Access**: NodePort 30080/30443
- **Configuration**: Repository credentials for GitHub

### ⚖️ **MetalLB**
- **Purpose**: LoadBalancer implementation for bare metal
- **Namespace**: `infrastructure`
- **Replicas**: 2 controllers + 2 speakers
- **Type**: L2 advertisement mode

### 🏷️ **Namespaces**
- **infrastructure**: Core infrastructure components
- **argocd**: GitOps controller and applications
- **ghost-dev**: Development environment (managed by ArgoCD)
- **ghost-staging**: Staging environment (managed by ArgoCD)
- **ghost-prod**: Production environment (managed by ArgoCD)
- **monitoring**: Observability stack (managed by ArgoCD)
- **logging**: Log aggregation (managed by ArgoCD)

## Deployment Workflow

### 1. **Infrastructure Provisioning** (Terraform)
```bash
# Apply infrastructure
terraform apply

# Get kubeconfig
export KUBECONFIG=$(terraform output -raw kube_config_path)

# Verify cluster
kubectl get nodes
```

### 2. **Application Deployment** (ArgoCD)
After Terraform completes:
1. ArgoCD is automatically installed
2. ApplicationSets detect environments
3. Applications are deployed automatically
4. All further changes are managed via GitOps

### 3. **Verification**
```bash
# Check ArgoCD applications
kubectl get applications -n argocd

# Check deployed pods
kubectl get pods -A

# Check services
kubectl get svc -A
```

## GitOps Structure

### ApplicationSets
- **Location**: `platform/argocd/applicationsets/`
- **Purpose**: Multi-environment application deployment
- **Environments**: dev, staging, prod
- **Components**: Ghost app + MySQL per environment

### Helm Charts
- **Ghost App**: `applications/ghost-app/helm/`
- **MySQL**: `infrastructure/mysql/helm/`
- **Platform Services**: `platform/manifests/`

### ArgoCD Projects
- **ghost-apps**: Application workloads
- **infrastructure**: Platform services

## Security Features

### 🔒 **Network Security**
- Isolated Docker network
- Controlled port mappings
- Network policies via ArgoCD

### 🔐 **Access Control**
- RBAC configured per namespace
- Service accounts for applications
- Sealed secrets management

### 🛡️ **Pod Security**
- Non-root containers
- Read-only filesystems
- Resource limits enforced

## Monitoring & Observability

### 📊 **Metrics**
- Prometheus operator
- Custom application metrics
- Infrastructure metrics

### 📈 **Visualization**
- Grafana dashboards
- Application performance metrics
- Infrastructure health

### 🚨 **Alerting**
- AlertManager routing
- Slack/email notifications
- Severity-based escalation

## Best Practices

### 🏗️ **Infrastructure as Code**
- Version-controlled configuration
- Automated provisioning
- Drift detection

### 🔄 **GitOps Workflow**
- Declarative configuration
- Automated deployments
- Rollback capabilities

### 🔒 **Security First**
- Policy as code enforcement
- Automated scanning
- Compliance tracking

## Troubleshooting

### Common Issues

1. **Cluster not ready**
   ```bash
   kubectl wait --for=condition=Ready nodes --all --timeout=300s
   ```

2. **ArgoCD not syncing**
   ```bash
   kubectl get applications -n argocd
   kubectl describe application <app-name> -n argocd
   ```

3. **MetalLB not working**
   ```bash
   kubectl get pods -n infrastructure
   kubectl logs -n infrastructure -l app.kubernetes.io/name=metallb
   ```

### Debug Commands

```bash
# Check cluster status
kubectl cluster-info

# Check all resources
kubectl get all -A

# Check ArgoCD status
kubectl argocd app list

# Terraform state
terraform show

# Destroy and recreate
terraform destroy && terraform apply
```

## Integration with CI/CD

The Terraform configuration is integrated into the CI/CD pipeline:

1. **Policy Validation**: Checkov, tfsec, OPA
2. **Infrastructure Plan**: Automated for PRs
3. **Infrastructure Apply**: Automated for main branch
4. **Application Deployment**: Handled by ArgoCD

## Next Steps

1. **Customize**: Adjust variables for your environment
2. **Extend**: Add additional infrastructure components
3. **Monitor**: Set up alerting and dashboards
4. **Secure**: Implement additional policies
5. **Scale**: Add more nodes or environments
