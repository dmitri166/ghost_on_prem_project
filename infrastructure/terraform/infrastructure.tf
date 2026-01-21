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


# Install MetalLB for LoadBalancer support (infrastructure component)
resource "helm_release" "metallb" {
  provider = helm.after_cluster
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = data.kubernetes_namespace.infrastructure.metadata[0].name
  
  create_namespace = false
  
  depends_on = [data.kubernetes_namespace.infrastructure]
}

# Install ArgoCD for GitOps (infrastructure component)
resource "helm_release" "argocd" {
  provider = helm.after_cluster
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = data.kubernetes_namespace.argocd.metadata[0].name
  
  create_namespace = false
  
  depends_on = [data.kubernetes_namespace.argocd]
}
