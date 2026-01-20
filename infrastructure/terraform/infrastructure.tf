# Kubernetes provider configuration
provider "kubernetes" {
  config_path = "${path.cwd}/kubeconfig.yaml"
  alias = "after_cluster"
}

# Wait for kubeconfig file to exist
data "local_file" "kubeconfig" {
  filename = "${path.cwd}/kubeconfig.yaml"
  depends_on = [null_resource.wait_for_cluster]
}

# Create infrastructure namespaces (managed by Terraform)
resource "kubernetes_namespace" "infrastructure" {
  provider = kubernetes.after_cluster
  depends_on = [data.local_file.kubeconfig]
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
  provider = kubernetes.after_cluster
  depends_on = [data.local_file.kubeconfig]
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
