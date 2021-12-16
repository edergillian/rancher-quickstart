# Data for vSphere module

data "vsphere_datacenter" "datacenter" {
  name = "MAPA"
}

data "vsphere_datastore" "datastore" {
  name          = "VMware_Prod_Lin_Huawei0_Tier1_1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "ClusterMAPA"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "DvPn_Rede-52"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_folder" "folder" {
  path = "${data.vsphere_datacenter.datacenter.id}/vm/Rancher"
}

data "vsphere_virtual_machine" "template" {
  name          = "Template-Linux-Ubuntu-20-04-Rancher"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}