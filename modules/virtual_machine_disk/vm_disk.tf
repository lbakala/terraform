variable "vm_storage_pool" { default = "pool" }
variable "vm_disk_name"    { description = "virtual machine disk name" }
variable "vm_disk_format"  { default = "qcow2" }
variable "vm_disk_source"  { default = "" }
variable "vm_disk_size"    { default = "" }

resource "libvirt_volume" "virtual_machine_volume" {
  name   = "${var.vm_disk_name}.qcow2"
  pool   = var.vm_storage_pool
  format = "qcow2"
  size   = var.vm_disk_size != "" ? var.vm_disk_size : null
  source = var.vm_disk_source != "" ?  var.vm_disk_source : null
}

output "vm_disk_id" {
value = "${libvirt_volume.virtual_machine_volume.id}"
}
