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

# Wait for cluster to be ready
resource "null_resource" "wait_for_cluster" {
  depends_on = [null_resource.create_cluster]
  
  provisioner "local-exec" {
    command = "k3d kubeconfig merge ${local.cluster_name} > kubeconfig.yaml && kubectl --kubeconfig=kubeconfig.yaml wait --for=condition=Ready nodes --all --timeout=300s"
  }
}

# Create and save kubeconfig
resource "local_file" "kubeconfig" {
  content  = <<-EOT
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: ""
        server: https://localhost:6443
      name: ${local.cluster_name}
    contexts:
    - context:
        cluster: ${local.cluster_name}
        user: ${local.cluster_name}
      name: ${local.cluster_name}
    current-context: ${local.cluster_name}
    kind: Config
    preferences: {}
    users:
    - name: ${local.cluster_name}
      user:
        client-certificate-data: ""
        client-key-data: ""
  EOT
  filename = "${path.module}/kubeconfig.yaml"
  
  depends_on = [null_resource.create_cluster]
}
