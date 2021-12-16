data "rancher2_node_template" "master_template" {
  name = var.cluster_master_pool_template
}

data "rancher2_node_template" "worker-template" {
  name = var.cluster_worker_pool_template
}

resource "rancher2_cluster" "cluster" {
  cluster_auth_endpoint {

  }
  cluster_monitoring_input {
    answers = {
      "exporter-kubelets.https"                   = "true",
      "exporter-node.enabled"                     = "true",
      "exporter-node.ports.metrics.port"          = "9796",
      "exporter-node.resources.limits.cpu"        = "200m",
      "exporter-node.resources.limits.memory"     = "200Mi",
      "grafana.persistence.enabled"               = "false",
      "grafana.persistence.size"                  = "10Gi",
      "grafana.persistence.storageClass"          = "default",
      "operator-init.enabled"                     = "true",
      "operator.resources.limits.memory"          = "500Mi",
      "prometheus.persistence.enabled"            = "false",
      "prometheus.persistence.size"               = "50Gi",
      "prometheus.persistence.storageClass"       = "default",
      "prometheus.persistent.useReleaseName"      = "true",
      "prometheus.resources.core.limits.cpu"      = "1000m",
      "prometheus.resources.core.limits.memory"   = "1000Mi",
      "prometheus.resources.core.requests.cpu"    = "750m",
      "prometheus.resources.core.requests.memory" = "750Mi",
      "prometheus.retention"                      = "12h"
    }
    version = "0.1.4"
  }
  name = var.cluster_name
  rke_config {
    ## Uncomment lines below to enable external Cloud Provider configuration
    ## If done, Cloud Provider must be configured before cluster is usable
    # cloud_provider {
    #   custom_cloud_provider = ""
    #   name                  = "external"
    # }
    dns {
      linear_autoscaler_params {
        cores_per_replica            = "128"
        max                          = "0"
        min                          = "1"
        nodes_per_replica            = "4"
        prevent_single_point_failure = "true"
      }
      node_selector = {}
      nodelocal {
        ip_address    = ""
        node_selector = {}
      }
      reverse_cidrs = []
      update_strategy {
        rolling_update {

        }
      }
      upstream_nameservers = [
        "<dns_server_1>",
        "<dns_server_2>"
      ]
    }
    ingress {
      extra_args = {
        "default-ssl-certificate" = "<path/to/certificate/secret>"
      }
      provider = "nginx"
    }
    kubernetes_version = "v1.20.6-rancher1-1"
    services {
      kube_controller {
        extra_args = {
          "cluster-signing-cert-file" = "/etc/kubernetes/ssl/kube-ca.pem",
          "cluster-signing-key-file"  = "/etc/kubernetes/ssl/kube-ca-key.pem"
        }
      }
      kubelet {
        extra_args = {
          "cloud-provider" = "external"
        }
        extra_binds = [
          "/csi:/csi:rshared",
          "/var/lib/csi/sockets/pluginproxy/csi.vsphere.vmware.com:/var/lib/csi/sockets/pluginproxy/csi.vsphere.vmware.com:rshared"
        ]
      }
    }
  }
}

resource "rancher2_node_pool" "master_pool" {
  name             = "${var.cluster_name}-master-pool"
  cluster_id       = rancher2_cluster.cluster.id
  hostname_prefix  = "${var.cluster_name}-m-"
  node_template_id = data.rancher2_node_template.master_template.id
  quantity         = var.cluster_master_pool_nodes
  control_plane    = true
  etcd             = true
  worker           = false
}

resource "rancher2_node_pool" "worker_pool" {
  name             = "${var.cluster_name}-worker-pool"
  cluster_id       = rancher2_cluster.cluster.id
  hostname_prefix  = "${var.cluster_name}-w-"
  node_template_id = data.rancher2_node_template.worker-template.id
  quantity         = var.cluster_worker_pool_nodes
  control_plane    = false
  etcd             = false
  worker           = true
}
