# Configure the VMware vSphere Provider
provider "vsphere" {
    vsphere_server = "${var.vsphere_vcenter}"
    user = "${var.vsphere_user}"
    password = "${var.vsphere_password}"
    allow_unverified_ssl = true
}
data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}
data "vsphere_datastore" "datastore" {
  name = "vsanDatastore"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
 
data "vsphere_compute_cluster" "cluster" {
  name = "MEGA-03"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_resource_pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
 
data "vsphere_network" "network" {
  name = "TPM03-740-1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
 
data "vsphere_virtual_machine" "windows_template" {
  name = "WIn19_Template"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_virtual_machine" "Ubuntu2004_template" {
  name          = "TPM04-MC/TPM04-Ubuntu-2004-Template"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_virtual_machine" "Ubuntu1804_template" {
  name          = "TPM04-MC/TPM04-Ubuntu-1804-Template"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_virtual_machine" "CentOS_template" {
  name          = "TPM03-AS/TPM03-CENTOS7-TEMPLATE"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}