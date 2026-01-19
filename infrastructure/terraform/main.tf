terraform {
  required_version = ">= 1.5.0"
  required_providers {
    k3d = {
      source  = "k3d-io/k3d"
      version = "~> 0.7"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Local values for configuration
locals {
  cluster_name = "ghost-k3d"
  k3s_version  = "v1.28.3+k3s.1"
  
  # Network configuration
  cluster_cidr = "10.42.0.0/16"
  service_cidr = "10.43.0.0/16"
  
  # Node configuration for 1 master + 2 workers
  master_nodes = 1
  worker_nodes = 2
  
  # Ports configuration
  api_port    = 6443
  http_port   = 80
  https_port  = 443
}

# Create k3d cluster with 1 master + 2 workers
resource "k3d_cluster" "main" {
  name    = local.cluster_name
  image   = local.k3s_version
  servers = local.master_nodes
  agents  = local.worker_nodes
  
  # Network configuration
  network {
    name = "k3d-${local.cluster_name}-net"
  }
  
  # Port mapping for external access
  ports {
    host_port      = local.api_port
    container_port = 6443
    node_filters   = ["server:*"]
  }
  
  ports {
    host_port      = local.http_port
    container_port = 80
    node_filters   = ["server:*"]
  }
  
  ports {
    host_port      = local.https_port
    container_port = 443
    node_filters   = ["server:*"]
  }
  
  # Kubeconfig configuration
  kubeconfig {
    update_default_kubeconfig = false
    switch_current_context     = false
  }
  
  # Disable built-in services (will be managed by ArgoCD)
  k3s_args {
    node_filters = ["server:*"]
    arguments   = [
      "--disable=traefik",
      "--disable=servicelb",
      "--disable=metrics-server",
      "--kubelet-arg=container-log-max-size=10M",
      "--kubelet-arg=container-log-max-files=3",
      "--write-kubeconfig-mode=644"
    ]
  }
  
  # Labels for cluster identification
  labels = {
    "environment" = "development"
    "managed-by" = "terraform"
    "project"    = "ghost-platform"
  }
}

# Create and save kubeconfig
resource "local_file" "kubeconfig" {
  content  = k3d_cluster.main.kubeconfig_raw
  filename = "${path.module}/kubeconfig.yaml"
  
  depends_on = [k3d_cluster.main]
}

# Wait for cluster to be ready
resource "null_resource" "wait_for_cluster" {
  depends_on = [k3d_cluster.main]
  
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local_file.kubeconfig.filename} wait --for=condition=Ready nodes --all --timeout=300s"
  }
}
