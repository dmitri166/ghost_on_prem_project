variable "cluster_name" {
  description = "Name of the k3d cluster"
  type        = string
  default     = "ghost-k3d"
}

variable "k3s_version" {
  description = "k3s version to deploy"
  type        = string
  default     = "v1.28.3+k3s.1"
}

variable "cluster_cidr" {
  description = "CIDR for pod network"
  type        = string
  default     = "10.42.0.0/16"
}

variable "service_cidr" {
  description = "CIDR for service network"
  type        = string
  default     = "10.43.0.0/16"
}

variable "master_nodes" {
  description = "Number of master nodes"
  type        = number
  default     = 1
}

variable "worker_nodes" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "api_port" {
  description = "Kubernetes API port"
  type        = number
  default     = 6443
}

variable "http_port" {
  description = "HTTP port for external access"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS port for external access"
  type        = number
  default     = 443
}
