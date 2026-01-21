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

# Create infrastructure namespaces (managed by Terraform)
resource "kubernetes_namespace" "infrastructure" {
  provider = kubernetes.after_cluster
  depends_on = [data.kubernetes_namespace.infrastructure]
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
  depends_on = [data.kubernetes_namespace.argocd]
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
  provider = helm.after_cluster
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = data.kubernetes_namespace.infrastructure.metadata[0].name
  
  create_namespace = false
  
  set {
    name  = "controller.replicaCount"
    value = "2"
  }
  
  set {
    name  = "speaker.replicaCount"
    value = "2"
  }
  
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
  
  set {
    name  = "server.insecure"
    value = "true"
  }
  
  set {
    name  = "configs.secret.argocdServerTlsConfig.secretname"
    value = "argocd-server-tls"
  }
  
  set {
    name  = "configs.secret.argocdServerTlsConfig.crtname"
    value = "argocd-server-tls-crt"
  }
  
  set {
    name  = "configs.secret.argocdServerTlsConfig.keyname"
    value = "argocd-server-tls-key"
  }
  
  set {
    name  = "server.additionalApplications"
    value = "true"
  }
  
  set {
    name  = "server.additionalApplicationSources"
    value = "true"
  }
  
  set {
    name  = "crds.install"
    value = "true"
  }
  
  set {
    name  = "notifications.enabled"
    value = "true"
  }
  
  set {
    name  = "notifications.argocdNotifications.notifiers.service.slack"
    value = "true"
  }
  
  set {
    name  = "notifications.argocdNotifications.notifiers.service.slack.username"
    value = "argocd"
  }
  
  set {
    name  = "notifications.argocdNotifications.notifiers.service.slack.token"
    value = "xoxb-3595148752-4199-4255-8340-990814965876"
  }
  
  depends_on = [data.kubernetes_namespace.argocd]
}
