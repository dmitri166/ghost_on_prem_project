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
    command = <<-EOT
      k3d cluster create ${local.cluster_name} \
        --servers ${local.master_nodes} \
        --agents ${local.worker_nodes} \
        --image ${local.k3s_version} \
        --port ${local.api_port} \
        --network k3d-${local.cluster_name}-net
    EOT
  }
}

# Wait for cluster to be ready
resource "null_resource" "wait_for_cluster" {
  depends_on = [null_resource.create_cluster]
  
  provisioner "local-exec" {
    command = <<-EOT
      k3d kubeconfig merge ${local.cluster_name} > kubeconfig.yaml
      kubectl --kubeconfig=kubeconfig.yaml wait --for=condition=Ready nodes --all --timeout=300s
    EOT
  }
}

# Create and save kubeconfig
resource "local_file" "kubeconfig" {
  content  = <<-EOT
    $(k3d kubeconfig get ${local.cluster_name})
  EOT
  filename = "${path.module}/kubeconfig.yaml"
  
  depends_on = [null_resource.create_cluster]
}
