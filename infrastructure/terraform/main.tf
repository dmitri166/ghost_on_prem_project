# Local values for configuration
locals {
  cluster_name   = "ghost-k3d"
  k3s_version    = "rancher/k3s:v1.28.8-k3s2"
  master_nodes   = 1
  worker_nodes   = 2
  cluster_cidr   = "10.42.0.0/16"
  service_cidr   = "10.43.0.0/16"
  api_port       = 6443
  http_port      = 80
  https_port     = 443
}

# Cluster is created in CI/CD before Terraform runs
# This ensures kubeconfig exists before providers initialize

# Check if Kyverno is already installed
resource "null_resource" "check_kyverno" {
  
  provisioner "local-exec" {
    command = "KUBECONFIG=kubeconfig.yaml helm list -n kyverno-system | grep -q kyverno && echo 'Kyverno already installed, will upgrade' || echo 'Kyverno not installed, will install fresh'"
  }
}
