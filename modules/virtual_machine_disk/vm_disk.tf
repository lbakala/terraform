variable "vm_storage_pool" { default = "pool" }
variable "vm_disk_name"    { description = "virtual machine disk name" }
variable "vm_disk_format"  { default = "qcow2" }
variable "vm_disk_source"  { default = "" }
variable "vm_disk_size"    { default = "" }

locals {
  debianv12 = "/opt/storage/template/template-4x-no-swap.qcow2"
  almav9    = "/opt/storage/template/template-4x-no-swap.qcow2"
  unknow    = "unknow"
}

resource "libvirt_volume" "virtual_machine_volume_default" {
  name   = "${local.unknow}-${var.vm_disk_name}.qcow2"
  pool   = var.vm_storage_pool
  format = var.vm_disk_format
  source = var.vm_disk_source == "debian12" ?  local.debianv12 : var.vm_disk_source == "alma9" ? local.almav9 : null
  size   = var.vm_disk_source != "" ?  null : 1000
}

resource "libvirt_volume" "virtual_machine_volume" {
  name   = "${var.vm_disk_name}.qcow2"
  pool   = var.vm_storage_pool
  format = var.vm_disk_format
  size   = var.vm_disk_size != "" ? var.vm_disk_size : null
  base_volume_id = libvirt_volume.virtual_machine_volume_default.id
}

output "vm_disk_id" {
value = "${libvirt_volume.virtual_machine_volume.id}"
}

