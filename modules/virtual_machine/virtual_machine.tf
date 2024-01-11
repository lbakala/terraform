variable "vm_name"         { description = "virtual machine name" }
variable "vm_memory"       { description = "virtual machine memory"}
variable "vm_vcpu"         { description = "virtual machine vcpu" }
variable "vm_network"      { description = "virtual machine name" }
variable "vm_disk"         { default     = "" }
variable "bastion_host"    { default     = "" }
variable "bastion_user"    { default     = "" }
variable "user"            { description = "host server" }
variable "host_password"   { description = "host password"}
variable "pubkey"          { default     = "" }
variable "destination"     { default     = "" }
variable "permission"      { default     = 400 }
variable "owner"           { default     = "user"}
variable "group"           { default     = "user"}
variable "vm_network_mac"  { default     = "" }
#------------------------------------------------------------------
resource "libvirt_domain" "virtual_machine" {
  name   = var.vm_name
  memory = var.vm_memory
  vcpu   = var.vm_vcpu
  network_interface {
    network_name = var.vm_network
    mac  = var.vm_network_mac != "" ? var.vm_network_mac : null 
  }
 dynamic "disk" {
   for_each = var.vm_disk
    content {
      volume_id = disk.value
    }
  }
  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
depends_on = [null_resource.disk_mappings]
}
#------------------------------------------------------------------
resource "time_sleep" "wait_12_seconds" {
  create_duration = "90s"
depends_on = [libvirt_domain.virtual_machine] 
}
#------------------------------------------------------------------
data external "set_resize_disk" {
  program = ["python3", "${path.module}/scripts/grows_disk.py"]
  query = {
  disk_volume = "${null_resource.disk_mappings[0].triggers.volume_id}"
  }
}
#------------------------------------------------------------------
data external "set_publikey" {
  program = ["python3", "${path.module}/scripts/addpubkey.py"]
  query = {
  pub_key = var.pub_keys
  }
}
#------------------------------------------------------------------
data external "server_configuration" {
  program = ["python3", "${path.module}/scripts/configuration.py"]
  query = {
  vm_name = "${libvirt_domain.virtual_machine.name}"
  }
}
#------------------------------------------------------------------
data "template_file" "JumpHost" {
template = file("${path.module}/templates/jumphost.tpl")
  vars = {
    short_host = "${var.vm_name}"
    ip         = "${data.external.get_info_ip.result.ip}"
    bastion    = "192.168.122.104"
  }
}
#------------------------------------------------------------------
resource "null_resource" "local" {
  triggers = {
    #template = "${data.template_file.JumpHost.rendered}"
    #always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "echo  \"${data.template_file.JumpHost.rendered}\" > /etc/ssh/ssh_config.d/${var.vm_name}.conf"
  }
}
#------------------------------------------------------------------
output "list_disk" {
value = null_resource.disk_mappings.*.triggers
}
output "vm_info" {
value = "${data.external.get_info_ip.result}"
}
