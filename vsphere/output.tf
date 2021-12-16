output "rancher_server_url" {
  value = module.rancher_common.rancher_url
}

output "rancher_node_ip" {
  value = vsphere_virtual_machine.rancher_server.default_ip_address
}

# output "workload_node_ip" {
#   value = vsphere_virtual_machine.workload.default_ip_address
# }
