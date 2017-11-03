variable "vsphere_user" {
  type    = "string"
  default = "administrator@unixcraft.uk"
}

variable  "docker_disksize" {
  default = 30
}

variable  "gfs_disksize" {
  default = 50
}

variable "vsphere_password" {}

variable "vsphere_server" {
  type    = "string"
  default = "192.168.10.253"
}

variable "vsphere_datacenter" {}
variable "vsphere_cluster" {}
variable "vsphere_domain" {}


variable "vsphere_template" {
  type    = "string"
  default = "Centos_7_Master_Template"
}

variable "vsphere_datastore" {
  type = "map"

  default = {
    nfs_sata = "VMW_SATA_NFS01"
    nfs_ssd  = "VMW_SSD_NFS01"
  }
}

variable "os_master_name" {
  type = "map"

  default = {
    "0" = "osmaster01"
    "1" = "osmaster02"
    "2" = "osmaster03"
  }
}

variable "os_infra_name" {
  type = "map"

  default = {
    "0" = "osinfra01"
    "1" = "osinfra02"
    "2" = "osinfra03"
  }
}

variable "os_node_name" {
  type = "map"

  default = {
    "0" = "osnode01"
    "1" = "osnode02"
    "2" = "osnode03"
  }
}

variable "os_master_ip" {
  type = "map"

  default = {
    "0" = "192.168.10.52"
    "1" = "192.168.10.53"
    "2" = "192.168.10.54"
  }
}

variable "os_infra_ip" {
  type = "map"

  default = {
    "0" = "192.168.10.92"
    "1" = "192.168.10.93"
    "2" = "192.168.10.94"
  }
}

variable "os_node_ip" {
  type = "map"

  default = {
    "0" = "192.168.10.62"
    "1" = "192.168.10.63"
    "2" = "192.168.10.64"
    "3" = "192.168.10.65"
  }
}
