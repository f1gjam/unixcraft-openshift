provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

resource "vsphere_virtual_machine" "osmaster" {
  count      = 1
  name       = "${lookup(var.os_master_name, count.index)}"
  domain     = "${var.vsphere_domain}"
  vcpu       = 2
  memory     = 8192
  datacenter = "${var.vsphere_datacenter}"
  cluster    = "${var.vsphere_cluster}"

  dns_suffixes = ["lab.unixcraft.lcl"]
  dns_servers  = ["192.168.10.51"]

  network_interface {
    label              = "VM Network"
    ipv4_address       = "${lookup(var.os_master_ip, count.index)}"
    ipv4_prefix_length = "24"
    ipv4_gateway       = "192.168.10.254"
  }

  disk {
    datastore = "${var.vsphere_datastore["nfs_ssd"]}"
    template  = "${var.vsphere_template}"
    type      = "thin"
  }

    disk {
        datastore = "${var.vsphere_datastore["nfs_ssd"]}"
        name = "${lookup(var.os_master_name, count.index)}_2"
        type      = "thin"
        size = "${var.docker_disksize}"
        type = "thin"
    }

}


resource "vsphere_virtual_machine" "osinfra" {
  count      = 1
  name       = "${lookup(var.os_infra_name, count.index)}"
  domain     = "${var.vsphere_domain}"
  vcpu       = 2
  memory     = 16384
  datacenter = "${var.vsphere_datacenter}"
  cluster    = "${var.vsphere_cluster}"

  dns_suffixes = ["lab.unixcraft.lcl"]
  dns_servers  = ["192.168.10.51"]

  network_interface {
    label              = "VM Network"
    ipv4_address       = "${lookup(var.os_infra_ip, count.index)}"
    ipv4_prefix_length = "24"
    ipv4_gateway       = "192.168.10.254"
  }

  disk {
    datastore = "${var.vsphere_datastore["nfs_ssd"]}"
    template  = "${var.vsphere_template}"
    type      = "thin"
  }

    disk {
        datastore = "${var.vsphere_datastore["nfs_ssd"]}"
        name = "${lookup(var.os_master_name, count.index)}_2"
        type      = "thin"
        size = "${var.docker_disksize}"
        type = "thin"
    }

}


resource "vsphere_virtual_machine" "osnode" {
  count      = 3
  name       = "${lookup(var.os_node_name, count.index)}"
  domain     = "${var.vsphere_domain}"
  vcpu       = 2
  memory     = 16384
  datacenter = "${var.vsphere_datacenter}"
  cluster    = "${var.vsphere_cluster}"

  dns_suffixes = ["lab.unixcraft.lcl"]
  dns_servers  = ["192.168.10.51"]

  network_interface {
    label              = "VM Network"
    ipv4_address       = "${lookup(var.os_node_ip, count.index)}"
    ipv4_prefix_length = "24"
    ipv4_gateway       = "192.168.10.254"
  }

  disk {
    datastore = "${var.vsphere_datastore["nfs_ssd"]}"
    template  = "${var.vsphere_template}"
    type      = "thin"
  }

   disk {
       datastore = "${var.vsphere_datastore["nfs_ssd"]}"
       name = "${lookup(var.os_node_name, count.index)}_2"
       type      = "thin"
       size = "${var.docker_disksize}"
       type = "thin"
   }
  ### GFS Drives ####
   disk {
         datastore = "${var.vsphere_datastore["nfs_ssd"]}"
         name = "${lookup(var.os_master_name, count.index)}_GFS"
         type      = "thin"
         size = "${var.gfs_disksize}"
         type = "thin"
     }
}
