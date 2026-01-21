# Kubernetes provider configuration
provider "kubernetes" {
  config_path = "${path.cwd}/kubeconfig.yaml"
  alias = "after_cluster"
}

# Reference existing namespaces (best practice for existing clusters)
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

# Reference existing MetalLB installation
data "helm_release" "metallb" {
  provider = helm.after_cluster
  name    = "metallb"
  namespace = data.kubernetes_namespace.infrastructure.metadata[0].name
}

# Reference existing ArgoCD installation
data "helm_release" "argocd" {
  provider = helm.after_cluster
  name    = "argocd"
  namespace = data.kubernetes_namespace.argocd.metadata[0].name
}

# Reference existing Kyverno installation
data "helm_release" "kyverno" {
  provider = helm.after_cluster
  name    = "kyverno"
  namespace = data.kubernetes_namespace.kyverno_system.metadata[0].name
}
