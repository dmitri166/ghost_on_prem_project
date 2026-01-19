output "cluster_name" {
  description = "The name of the k3d cluster"
  value       = local.cluster_name
}

output "kube_config_path" {
  description = "Path to kubeconfig file"
  value       = local_file.kubeconfig.filename
}

output "cluster_endpoint" {
  description = "The Kubernetes API endpoint"
  value       = "https://localhost:6443"
}

output "cluster_version" {
  description = "The k3s version"
  value       = local.k3s_version
}

output "master_nodes" {
  description = "Number of master nodes"
  value       = local.master_nodes
}

output "worker_nodes" {
  description = "Number of worker nodes"
  value       = local.worker_nodes
}

output "total_nodes" {
  description = "Total number of nodes"
  value       = local.master_nodes + local.worker_nodes
}

output "cluster_cidr" {
  description = "Pod network CIDR"
  value       = local.cluster_cidr
}

output "service_cidr" {
  description = "Service network CIDR"
  value       = local.service_cidr
}
