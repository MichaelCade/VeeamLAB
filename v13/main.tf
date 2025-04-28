provider "vsphere" {
  user                 = "administrator@vzilla.local"
  password             = "SUPERSECUREPASSWORD"
  vsphere_server       = "192.168.169.181"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "vZilla DC"
}

data "vsphere_datastore" "datastore" {
  name          = "VMware_NFS_716"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "vZilla Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "veeam_vm" {
  count            = 2
  name             = "Veeam-Appliance-${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = "Veeam"
  firmware         = "efi"

  num_cpus = 2
  memory   = 10240
  guest_id = "rhel8_64Guest"

  scsi_type = "lsilogic"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "os-disk"
    size             = 256
    unit_number      = 0
    eagerly_scrub    = false
    thin_provisioned = true
  }

  disk {
    label            = "data-disk"
    size             = 256
    unit_number      = 1
    eagerly_scrub    = false
    thin_provisioned = true
  }

  cdrom {
  client_device = true
}


  wait_for_guest_net_timeout = 0
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "veeam_anti_affinity" {
  name               = "veeam-vm-anti-affinity"
  enabled            = true
  compute_cluster_id = data.vsphere_compute_cluster.cluster.id

  virtual_machine_ids = [
    for vm in vsphere_virtual_machine.veeam_vm : vm.id
  ]

  depends_on = [vsphere_virtual_machine.veeam_vm]
}
