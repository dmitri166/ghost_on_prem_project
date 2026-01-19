# Kubernetes provider configuration
provider "kubernetes" {
  host                   = k3d_cluster.main.endpoint
  cluster_ca_certificate = base64decode(k3d_cluster.main.cluster_ca_certificate)
  token                  = k3d_cluster.main.token
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    host                   = k3d_cluster.main.endpoint
    cluster_ca_certificate = base64decode(k3d_cluster.main.cluster_ca_certificate)
    token                  = k3d_cluster.main.token
  }
}

# Create infrastructure namespaces (managed by Terraform)
resource "kubernetes_namespace" "infrastructure" {
  metadata {
    name = "infrastructure"
    labels = {
      name        = "infrastructure"
      managed-by  = "terraform"
      environment = "production"
      purpose     = "cluster-infrastructure"
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name        = "argocd"
      managed-by  = "terraform"
      environment = "production"
      purpose     = "gitops-controller"
    }
  }
}

# Install MetalLB for LoadBalancer support (infrastructure component)
resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = "infrastructure"
  
  create_namespace = false
  
  set {
    name  = "controller.replicaCount"
    value = "2"
  }
  
  set {
    name  = "speaker.replicaCount"
    value = "2"
  }
  
  depends_on = [kubernetes_namespace.infrastructure]
}

# Install ArgoCD (infrastructure component)
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  
  create_namespace = false
  
  set {
    name  = "server.service.type"
    value = "NodePort"
  }
  
  set {
    name  = "server.service.nodePortHttp"
    value = "30080"
  }
  
  set {
    name  = "server.service.nodePortHttps"
    value = "30443"
  }
  
  set {
    name  = "configs.credentialTemplates[0].name"
    value = "repo-creds"
  }
  
  set {
    name  = "configs.credentialTemplates[0].url"
    value = "https://github.com/dmitri166/ghost_on_prem_project"
  }
  
  set {
    name  = "configs.credentialTemplates[0].type"
    value = "git"
  }
  
  depends_on = [kubernetes_namespace.argocd]
}
