# Variables for AWS infrastructure module

// TODO - use null defaults

# Required
variable "vsphere_server" {
  type        = string
  description = "vCenter Server for provisioning"
}

# Required
variable "vsphere_user" {
  type        = string
  description = "vCenter User for provisioning"
}

# Required
variable "vsphere_password" {
  type        = string
  description = "vCenter Password for provisioning"
}

variable "docker_version" {
  type        = string
  description = "Docker version to install on nodes"
  default     = "19.03"
}

variable "rancher_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for Rancher server cluster"
  default     = "v1.21.4+k3s1"
}

variable "workload_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for managed workload cluster"
  default     = "v1.20.6-rancher1-1"
}

variable "cert_manager_version" {
  type        = string
  description = "Version of cert-manager to install alongside Rancher (format: 0.0.0)"
  default     = "1.5.3"
}

variable "rancher_version" {
  type        = string
  description = "Rancher server version (format: v0.0.0)"
  default     = "v2.6.2"
}

# Required
variable "rancher_server_admin_password" {
  type        = string
  description = "Admin password to use for Rancher server bootstrap"
}

variable "cluster_name" {
  type        = string
  description = "Rancher-created K8s cluster name"
  default     = "lab"
}

variable "cluster_master_pool_template" {
  type        = string
  description = "etcd and control-plane node template"
  default     = "lab-controlplane"
}

variable "cluster_worker_pool_template" {
  type        = string
  description = "Worker node template"
  default     = "lab-worker"
}

variable "cluster_master_pool_nodes" {
  type        = number
  description = "Number of etcd/control-plane nodes"
  default     = 1
}

variable "cluster_worker_pool_nodes" {
  type        = number
  description = "Number of worker nodes"
  default     = 1
}

# Local variables used to reduce repetition
locals {
  node_username = "ubuntu"
}
