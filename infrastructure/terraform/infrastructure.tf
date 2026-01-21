# Kubernetes provider configuration
provider "kubernetes" {
  config_path = "${path.cwd}/kubeconfig.yaml"
  alias = "after_cluster"
}

# Variables for best practice configuration
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# Check what namespaces exist (best practice: discover existing)
data "kubernetes_namespace" "infrastructure" {
  provider = kubernetes.after_cluster
  metadata {
    name = "infrastructure"
  }
}

data "kubernetes_namespace" "argocd" {
  provider = kubernetes.after_cluster
  metadata {
    name = "argocd"
  }
}

data "kubernetes_namespace" "kyverno_system" {
  provider = kubernetes.after_cluster
  metadata {
    name = "kyverno-system"
  }
}

# Check if Ghost namespaces exist
data "kubernetes_namespace" "ghost_dev" {
  provider = kubernetes.after_cluster
  metadata {
    name = "ghost-dev"
  }
}

data "kubernetes_namespace" "ghost_staging" {
  provider = kubernetes.after_cluster
  metadata {
    name = "ghost-staging"
  }
}

data "kubernetes_namespace" "ghost_prod" {
  provider = kubernetes.after_cluster
  metadata {
    name = "ghost-prod"
  }
}

# Infrastructure only - applications are deployed by ArgoCD
