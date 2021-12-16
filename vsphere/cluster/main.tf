terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.21.0"
    }
  }
}

variable "cluster_name" {

}

variable "cluster_master_pool_template" {

}

variable "cluster_worker_pool_template" {

}

variable "cluster_master_pool_nodes" {

}

variable "cluster_worker_pool_nodes" {

}
