# AWS Rancher Quickstart

Two single-node RKE Kubernetes clusters will be created from two EC2 instances running SLES 15 and Docker.
Both instances will have wide-open security groups and will be accessible over SSH using the SSH keys
`id_rsa` and `id_rsa.pub`.

## Variables

###### `vsphere_server`
- **Required**
vCenter Server for provisioning

###### `vsphere_user`
- **Required**
vCenter User for provisioning

###### `vsphere_password`
- Default: **`"us-east-1"`**
vCenter User for provisioning

###### `docker_version`
- Default: **`"19.03"`**
Docker version to install on nodes

###### `rancher_kubernetes_version`
- Default: **`"v1.21.4+k3s1"`**
Kubernetes version to use for Rancher server cluster

See `rancher-common` module variable `rancher_kubernetes_version` for more details.

###### `cert_manager_version`
- Default: **`"1.5.3"`**
Version of cert-manager to install alongside Rancher (format: 0.0.0)

See `rancher-common` module variable `cert_manager_version` for more details.

###### `rancher_version`
- Default: **`"v2.6.2"`**
Rancher server version (format v0.0.0)

See `rancher-common` module variable `rancher_version` for more details.

###### `rancher_server_admin_password`
- **Required**
Admin password to use for Rancher server bootstrap

See `rancher-common` module variable `admin_password` for more details.

###### `cluster_name`
- Default: **`"lab"`**
Rancher-created K8s cluster name"

###### `cluster_master_pool_template`
- Default: **`"lab-controlplane"`**
etcd and control-plane node template"

###### `cluster_worker_pool_template`
- Default: **`"lab-worker"`**
Worker node template"

###### `cluster_master_pool_nodes`
- Default: **`1`**
Number of etcd/control-plane nodes"

###### `cluster_worker_pool_nodes`
- Default: **`1`**
Number of worker nodes"
