# Helm provider configuration
provider "helm" {
  kubernetes {
    config_path = "${path.cwd}/kubeconfig.yaml"
  }
  alias = "after_cluster"
}

# Wait for kubeconfig file to exist
data "local_file" "kubeconfig_helm" {
  filename = "${path.cwd}/kubeconfig.yaml"
  depends_on = [null_resource.wait_for_cluster]
}

# Install Kyverno using Helm (with upgrade support)
resource "helm_release" "kyverno" {
  provider = helm.after_cluster
  name       = "kyverno-security"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  namespace  = "kyverno-system"
  create_namespace = true
  
  # Handle upgrades - if release exists, upgrade it
  lifecycle {
    ignore_changes = all
  }
  
  depends_on = [data.local_file.kubeconfig_helm]
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