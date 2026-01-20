# Helm provider configuration
provider "helm" {
  kubernetes {
    config_path = "kubeconfig.yaml"
  }
  alias = "after_cluster"
}

# Install Kyverno using Helm
resource "helm_release" "kyverno" {
  provider = helm.after_cluster
  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  namespace  = "kyverno-system"
  create_namespace = true
  set {
    name = "kyverno"
  }
  
  depends_on = [null_resource.wait_for_cluster]
}

# Apply Kyverno policies after installation
resource "null_resource" "apply_policies" {
  depends_on = [helm_release.kyverno]
  
  provisioner "local-exec" {
    command = "kubectl apply -f ../../policy/kyverno/ && echo '✅ Kyverno policies applied successfully'"
  }
}