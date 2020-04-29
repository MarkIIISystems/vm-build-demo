variable "machine_name" {}
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "vm_request_id" {}
variable "vm_owner" {}
variable "admin_password" {}
variable "vm_size" {}
variable "vm_mem_size" {}
variable "vm_cpu_size" {}
variable "vsphere_datacenter" {}
variable "vsphere_storage" {}
variable "vsphere_cluster" {}
variable "vm_portgroup" {}
variable "vm_folder" {}
variable "vm_domain" {}
variable "resource_pool" {}
variable "organization" {}
variable "product_key" {}


provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  
# If you have a self-signed cert
allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vsphere_storage}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


data "vsphere_compute_cluster" "cluster" {
  name          = "${var.vsphere_cluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "CENTOS7"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.vm_portgroup}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name		= "${data.vsphere_compute_cluster.cluster.name}/Resources/${var.resource_pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_custom_attribute" "attr_owner" {
  name = "vm.owner"
}

data "vsphere_custom_attribute" "attr_provisioned" {
  name = "vm.provisioned"
}

data "vsphere_custom_attribute" "attr_request_id" {
  name = "vm.request_id"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "${var.machine_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder = "${var.vm_folder}"
  datastore_id = "${data.vsphere_datastore.datastore.id}"
  firmware = "bios"
  custom_attributes = {"${data.vsphere_custom_attribute.attr_owner.id}"="${var.vm_owner}",
		      "${data.vsphere_custom_attribute.attr_request_id.id}"="${var.vm_request_id}",
		      "${data.vsphere_custom_attribute.attr_provisioned.id}"="${timestamp()}"}


  network_interface {
  	network_id   = "${data.vsphere_network.network.id}"
  	adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }
  
  memory = "${lookup(var.vm_mem_size, var.vm_size)}"
  num_cpus = "${lookup(var.vm_cpu_size, var.vm_size)}"
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
  
  disk {
    label            = "${var.machine_name}_1"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
      host_name = "${var.machine_name}"
      domain    = "${var.vm_domain}"
      
      }
      
      network_interface {
      
     }    

    }
  }
}
