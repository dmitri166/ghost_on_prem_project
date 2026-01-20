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

# Create k3d cluster using local-exec (since k3d provider is not available)
resource "null_resource" "create_cluster" {
  provisioner "local-exec" {
    command = "if ! k3d cluster list | grep -q '${local.cluster_name}'; then k3d cluster create ${local.cluster_name} --servers ${local.master_nodes} --agents ${local.worker_nodes} --image ${local.k3s_version} --port ${local.api_port} --network k3d-${local.cluster_name}-net; else echo 'Cluster ${local.cluster_name} already exists, skipping creation'; fi"
  }
}

# Use existing k3d kubeconfig instead of creating new one
resource "null_resource" "wait_for_cluster" {
  depends_on = [null_resource.create_cluster]
  
  provisioner "local-exec" {
    command = "echo 'Using existing k3d kubeconfig' && k3d kubeconfig get ${local.cluster_name} > kubeconfig.yaml && echo 'Kubeconfig ready:' && ls -la kubeconfig.yaml"
  }
}

# Check if Kyverno is already installed
resource "null_resource" "check_kyverno" {
  depends_on = [null_resource.wait_for_cluster]
  
  provisioner "local-exec" {
    command = "KUBECONFIG=kubeconfig.yaml helm list -n kyverno-system | grep -q kyverno && echo 'Kyverno already installed, will upgrade' || echo 'Kyverno not installed, will install fresh'"
  }
}
