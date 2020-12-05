resource "vsphere_virtual_machine" "VBR" {
  name             = "${var.VBR_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${var.vsphere_folder}"
 
  num_cpus = 4
  memory   = 16384
  firmware = "${data.vsphere_virtual_machine.windows_template.firmware}"
  guest_id = "${data.vsphere_virtual_machine.windows_template.guest_id}"
 
  scsi_type = "${data.vsphere_virtual_machine.windows_template.scsi_type}"
 
  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.windows_template.network_interface_types[0]}"
  }
 
  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.windows_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.windows_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.windows_template.disks.0.thin_provisioned}"
  }


  clone {
    template_uuid = "${data.vsphere_virtual_machine.windows_template.id}"
 
    customize {
      windows_options {
        computer_name = "${var.VBR_name}"
        join_domain = "${var.Domain}"
        domain_admin_user = "${var.Domain_Admin}"
        domain_admin_password = "${var.Domain_Password}"
      }
 
      network_interface {
        ipv4_address = "${var.VBR_IP}"
        ipv4_netmask = 24
      }
      ipv4_gateway = "${var.Gateway}"
      dns_server_list = ["10.0.40.2", "10.0.0.2"]
    }
  }
}
resource "vsphere_virtual_machine" "WinProxy1" {
  name             = "${var.WinProxy_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${var.vsphere_folder}"
 
  num_cpus = 2
  memory   = 8096
  firmware = "${data.vsphere_virtual_machine.windows_template.firmware}"
  guest_id = "${data.vsphere_virtual_machine.windows_template.guest_id}"
 
  scsi_type = "${data.vsphere_virtual_machine.windows_template.scsi_type}"
 
  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.windows_template.network_interface_types[0]}"
  }
 
  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.windows_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.windows_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.windows_template.disks.0.thin_provisioned}"
  }


  clone {
    template_uuid = "${data.vsphere_virtual_machine.windows_template.id}"
 
    customize {
      windows_options {
        computer_name = "${var.WinProxy_name}"
        join_domain = "${var.Domain}"
        domain_admin_user = "${var.Domain_Admin}"
        domain_admin_password = "${var.Domain_Password}"
      }
 
      network_interface {
        ipv4_address = "${var.WinProxy_IP}"
        ipv4_netmask = 24
      }
      ipv4_gateway = "${var.Gateway}"
      dns_server_list = ["10.0.40.2", "10.0.0.2"]
    }
  }
}
resource "vsphere_virtual_machine" "LinProxy1" {
  name             = "${var.LinProxy_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${var.vsphere_folder}"

  num_cpus = 2
  memory   = 8096

  guest_id         = "${data.vsphere_virtual_machine.CentOS_template.guest_id}"
  memory_reservation  = "1024"

  scsi_type        = "${data.vsphere_virtual_machine.CentOS_template.scsi_type}"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.CentOS_template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.CentOS_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.CentOS_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.CentOS_template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.CentOS_template.id}"

    customize {
     linux_options {
        host_name = "${var.LinProxy_name}"
        domain    = "${var.Domain}"
      }
      network_interface {
        ipv4_address = "${var.LinProxy_IP}"
        ipv4_netmask = 24
      }
      ipv4_gateway = "${var.Gateway}"
      dns_server_list = ["10.0.40.2"]
      dns_suffix_list = ["${var.Domain}"]
    }
  }
}
resource "vsphere_virtual_machine" "XFSRepo" {
  name             = "${var.XFSRepo_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${var.vsphere_folder}"

  num_cpus = 2
  memory   = 8096

  guest_id         = "${data.vsphere_virtual_machine.Ubuntu1804_template.guest_id}"
  memory_reservation  = "1024"

  scsi_type        = "${data.vsphere_virtual_machine.Ubuntu1804_template.scsi_type}"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.Ubuntu1804_template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.Ubuntu1804_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.Ubuntu1804_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.Ubuntu1804_template.disks.0.thin_provisioned}"
  }  
  
  disk {
    label            = "disk1"
    size             = "500"
    eagerly_scrub    = "${data.vsphere_virtual_machine.Ubuntu1804_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.Ubuntu1804_template.disks.0.thin_provisioned}"
    unit_number      = "1" 
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.Ubuntu1804_template.id}"

    customize {
     linux_options {
        host_name = "${var.XFSRepo_name}"
        domain    = "${var.Domain}"
      }
      network_interface {
        ipv4_address = "${var.XFSRepo_IP}"
        ipv4_netmask = 24
      }
      ipv4_gateway = "${var.Gateway}"
      dns_server_list = ["10.0.40.2"]
      dns_suffix_list = ["${var.Domain}"]
    }
  }
}