# AWS infrastructure resources

resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_private_key_pem" {
  filename          = "${path.module}/id_rsa"
  sensitive_content = tls_private_key.global_key.private_key_pem
  file_permission   = "0600"
}

resource "local_file" "ssh_public_key_openssh" {
  filename = "${path.module}/id_rsa.pub"
  content  = tls_private_key.global_key.public_key_openssh
}

data "template_cloudinit_config" "example" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
      #cloud-config
      hostname: rancher-server-test
      users:
        - name: ubuntu
          passwd: ''
          lock_passwd: true
          ssh-authorized-keys:
            - ${file("${local_file.ssh_public_key_openssh.filename}")}
      disk_setup:
        /dev/sda:
          table_type: mbr
          layout:
            - [100, 83]
          overwrite: false
      fs_setup:
        - label: data
          device: /dev/sda1
          filesystem: ext4
          overwrite: false
      mounts:
        - [/dev/sda1, /data, ext4, 'defaults,discard,nofail', '0', '2']
      runcmd:
        - sed -i '/ubuntu insecure public key/d' /home/vagrant/.ssh/authorized_keys
        - usermod --expiredate '' ubuntu
      EOF
  }
}

# vSphere VM for creating a single node RKE cluster and installing the Rancher server
resource "vsphere_virtual_machine" "rancher_server" {
  name             = "rancher-server-test"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = data.vsphere_folder.folder.id

  num_cpus = 4
  memory   = 8192
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  extra_config = {
    "guestinfo.userdata"          = data.template_cloudinit_config.example.rendered
    "guestinfo.userdata.encoding" = "gzip+base64"
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "rancher-server-test"
        domain    = "agricultura.gov.br"
      }
    }
  }

  provisioner "remote-exec" {
    inline = [
      "id",
      "uname -a",
      "cat /etc/os-release",
      "echo \"machine-id is $(cat /etc/machine-id)\"",
      "lsblk -x KNAME -o KNAME,SIZE,TRAN,SUBSYSTEMS,FSTYPE,UUID,LABEL,MODEL,SERIAL",
      "mount | grep ^/dev",
      "df -h",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.default_ip_address
      private_key = file("${local_file.ssh_private_key_pem.filename}")
    }
  }
}

# Rancher resources
module "rancher_common" {
  source = "../rancher-common"

  node_public_ip             = vsphere_virtual_machine.rancher_server.default_ip_address
  node_internal_ip           = vsphere_virtual_machine.rancher_server.default_ip_address
  node_username              = local.node_username
  ssh_private_key_pem        = tls_private_key.global_key.private_key_pem
  rancher_kubernetes_version = var.rancher_kubernetes_version

  cert_manager_version = var.cert_manager_version
  rancher_version      = var.rancher_version

  rancher_server_dns = join(".", ["rancher", vsphere_virtual_machine.rancher_server.default_ip_address, "sslip.io"])

  admin_password = var.rancher_server_admin_password

  workload_kubernetes_version = var.workload_kubernetes_version
  workload_cluster_name       = "quickstart-vsphere-custom"

  windows_prefered_cluster = false
}

# AWS EC2 instance for creating a single node workload cluster
# resource "aws_instance" "quickstart_node" {
#   ami           = data.aws_ami.sles.id
#   instance_type = var.instance_type

#   key_name        = aws_key_pair.quickstart_key_pair.key_name
#   security_groups = [aws_security_group.rancher_sg_allowall.name]

#   user_data = templatefile(
#     join("/", [path.module, "files/userdata_quickstart_node.template"]),
#     {
#       docker_version   = var.docker_version
#       username         = local.node_username
#       register_command = module.rancher_common.custom_cluster_command
#     }
#   )

#   provisioner "remote-exec" {
#     inline = [
#       "echo 'Waiting for cloud-init to complete...'",
#       "cloud-init status --wait > /dev/null",
#       "echo 'Completed cloud-init!'",
#     ]

#     connection {
#       type        = "ssh"
#       host        = self.public_ip
#       user        = local.node_username
#       private_key = tls_private_key.global_key.private_key_pem
#     }
#   }

#   tags = {
#     Name    = "${var.prefix}-quickstart-node"
#     Creator = "rancher-quickstart"
#   }
# }

module "cluster" {
  source                       = "./cluster"
  cluster_name                 = var.cluster_name
  cluster_worker_pool_nodes    = var.cluster_worker_pool_nodes
  cluster_master_pool_nodes    = var.cluster_master_pool_nodes
  cluster_worker_pool_template = var.cluster_worker_pool_template
  cluster_master_pool_template = var.cluster_master_pool_template
}