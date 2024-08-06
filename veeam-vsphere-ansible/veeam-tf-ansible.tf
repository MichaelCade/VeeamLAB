terraform {
  required_version = ">= 1.0.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.0.0"
    }
  }
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_vcenter

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "windows_template" {
  name          = var.windows_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "VBR" {
  name             = var.VBR_name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vsphere_folder

  num_cpus = 4
  memory   = 8096
  firmware = data.vsphere_virtual_machine.windows_template.firmware
  guest_id = data.vsphere_virtual_machine.windows_template.guest_id

  scsi_type = data.vsphere_virtual_machine.windows_template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.windows_template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.windows_template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.windows_template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.windows_template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.windows_template.id

    customize {
      windows_options {
        computer_name         = var.VBR_name
        admin_password        = var.Windows_Password
        auto_logon            = true
        auto_logon_count      = 3

        run_once_command_list = [
          "cmd.exe /C Powershell.exe Invoke-WebRequest -Uri https://raw.githubusercontent.com/MichaelCade/VeeamLAB/master/userdata.ps1 -OutFile c:\\first.ps1",
          "cmd.exe /C Powershell.exe -ExecutionPolicy Bypass -File c:\\first.ps1",
        ]
      }

      network_interface {
        ipv4_address = var.VBR_IP
        ipv4_netmask = 23  # This corresponds to 255.255.254.0
      }
      ipv4_gateway    = var.Gateway
      dns_server_list = [var.dns1, var.dns2]
    }
  }
}

resource "vsphere_virtual_machine" "ONE" {
  name             = var.ONE_name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vsphere_folder

  num_cpus = 4
  memory   = 2048
  firmware = data.vsphere_virtual_machine.windows_template.firmware
  guest_id = data.vsphere_virtual_machine.windows_template.guest_id

  scsi_type = data.vsphere_virtual_machine.windows_template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.windows_template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.windows_template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.windows_template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.windows_template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.windows_template.id

    customize {
      windows_options {
        computer_name         = var.ONE_name
        admin_password        = var.Windows_Password
        auto_logon            = true
        auto_logon_count      = 3

        run_once_command_list = [
          "cmd.exe /C Powershell.exe Invoke-WebRequest -Uri https://raw.githubusercontent.com/MichaelCade/VeeamLAB/master/userdata.ps1 -OutFile c:\\first.ps1",
          "cmd.exe /C Powershell.exe -ExecutionPolicy Bypass -File c:\\first.ps1",
        ]
      }

      network_interface {
        ipv4_address = var.ONE_IP
        ipv4_netmask = 23  # This corresponds to 255.255.254.0
      }
      ipv4_gateway    = var.Gateway
      dns_server_list = [var.dns1, var.dns2]
    }
  }
}

# Add health checks to ensure machines are ready
resource "null_resource" "wait_for_vbr" {
  depends_on = [vsphere_virtual_machine.VBR]

  provisioner "local-exec" {
    command = "until nc -z ${var.VBR_IP} 22; do sleep 10; done"
  }
}

resource "null_resource" "wait_for_one" {
  depends_on = [vsphere_virtual_machine.ONE]

  provisioner "local-exec" {
    command = "until nc -z ${var.ONE_IP} 22; do sleep 10; done"
  }
}

# Run Ansible playbook for VBR
resource "null_resource" "ansible_playbook_vbr" {
  depends_on = [null_resource.wait_for_vbr]

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/ansible/inventory.ini ${path.module}/ansible/veeam_vbr.yaml"
    on_failure = continue
  }
}

# Run Ansible playbook for ONE
resource "null_resource" "ansible_playbook_one" {
  depends_on = [null_resource.wait_for_one]

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/ansible/inventory.ini ${path.module}/ansible/veeam_one.yaml"
    on_failure = continue
  }
}

