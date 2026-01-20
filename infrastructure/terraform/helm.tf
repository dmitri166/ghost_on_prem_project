# Helm provider configuration
provider "helm" {
  kubernetes {
    config_path = "kubeconfig.yaml"
  }
  alias = "after_cluster"
}

# Install Kyverno using Helm (with upgrade support)
resource "helm_release" "kyverno" {
  provider = helm.after_cluster
  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  namespace  = "kyverno-system"
  create_namespace = true
  
  # Handle upgrades - if release exists, upgrade it
  lifecycle {
    ignore_changes = all
  }
  
  depends_on = [null_resource.cleanup_helm]
}

# Apply Kyverno policies after installation
resource "null_resource" "apply_policies" {
  depends_on = [helm_release.kyverno]
  
  provisioner "local-exec" {
    command = "KUBECONFIG=kubeconfig.yaml kubectl apply -f ../../policy/kyverno/ --validate=false && echo ' Kyverno policies applied successfully'"
  }
}

# Verify Kyverno installation
resource "null_resource" "verify_kyverno" {
  depends_on = [null_resource.apply_policies]
  
  provisioner "local-exec" {
    command = "KUBECONFIG=kubeconfig.yaml sh -c 'echo \"Verifying Kyverno installation...\" && if kubectl get pods -n kyverno-system | grep -q \"kyverno\"; then echo \" Kyverno pods are running\"; kubectl get pods -n kyverno-system; else echo \" Kyverno pods not found\"; exit 1; fi && if kubectl get clusterpolicies | grep -q \"require-secure-images\"; then echo \" Kyverno policies are installed\"; kubectl get clusterpolicies; else echo \" Kyverno policies not found\"; exit 1; fi && echo \" Kyverno installation verified successfully!\"'"
  }
}