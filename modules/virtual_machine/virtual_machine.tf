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
data external "get_info_ip" {
  program = ["bash", "${path.module}/scripts/get_vm_ip"]
  query = {
  vm_name = "${libvirt_domain.virtual_machine.name}"
  }
depends_on = [time_sleep.wait_12_seconds]
}
#------------------------------------------------------------------
resource "null_resource" "ssh_configuration" {
  #triggers = {
  #always_run = "${timestamp()}"
  #}
  connection {
    type = "ssh"
    host = "${data.external.get_info_ip.result.ip}"
    user = var.user
    password = var.host_password
    bastion_private_key = "${file("~/.ssh/id_rsa")}"
    bastion_host = "192.168.122.104"
  }
  provisioner "remote-exec" {
    inline = [
      "rm -fr /home/user/.ssh",
      "mkdir -p /home/user/.ssh",
      "chown -R user: /home/user/.ssh",
      "sudo apt update -y",
      "sudo apt install python3 python3-apt -y",
      "sudo hostnamectl set-hostname ${var.vm_name}",
      "sudo echo 'net.ipv6.conf.all.disable_ipv6 = 1' | sudo tee /etc/sysctl.d/70-disable-ipv6.conf",
      "sudo sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf",
      ]
  }
  provisioner "file" {
    content     = var.pubkey      != "" ? var.pubkey : null
    destination = var.destination != "" ? var.destination : null
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
data external "check_dhcp_input" {
  program = ["bash", "${path.module}/scripts/check_dhcp_input"]
  query = {
  vm_name = "${libvirt_domain.virtual_machine.name}"
  }
}
#------------------------------------------------------------------
data "template_file" "dhcp" {
count = "${data.external.check_dhcp_input.result.value}" ? 1 : 0
template = file("${path.module}/templates/dhcp.tpl")
  vars = {
    short_host = "${var.vm_name}"
    mac        = "${libvirt_domain.virtual_machine.network_interface[0].mac}"
    ip         = "${data.external.get_info_ip.result.ip}"
  }
}
#------------------------------------------------------------------
 resource "null_resource" "add_dhcp_entry" {
 count = "${data.external.check_dhcp_input.result.value}" ? 1 : 0
   connection {
     type = "ssh"
     host = "192.168.122.104"
     user = var.user
     private_key = "${file("~/.ssh/id_rsa")}"
   }
  provisioner "remote-exec" {
    inline = [
            "echo  \"${data.template_file.dhcp[count.index].rendered}\" | sudo tee -a /etc/dhcp/dhcpd.conf", 
            "sudo systemctl restart isc-dhcp-server.service",
      ]
    }
 }
#------------------------------------------------------------------
data external "check_dns_input" {
  program = ["bash", "${path.module}/scripts/check_dns_input"]
  query = {
  vm_name = "${libvirt_domain.virtual_machine.name}"
  }
}
#------------------------------------------------------------------
data "template_file" "dns_reverse" {
count = "${data.external.check_dns_input.result.value}" ? 1 : 0
template = file("${path.module}/templates/dns_reverse.tpl")
  vars = {
    short_host  = "${var.vm_name}"
    host        = split(".","${data.external.get_info_ip.result.ip}")[4]
    ip          = "${data.external.get_info_ip.result.ip}"
  }
}
#------------------------------------------------------------------
data "template_file" "dns_forward" {
count = "${data.external.check_dns_input.result.value}" ? 1 : 0
template = file("${path.module}/templates/dns_forward.tpl")
  vars = {
    short_host  = "${var.vm_name}"
    ip          = "${data.external.get_info_ip.result.ip}"
  }
}
#------------------------------------------------------------------
 resource "null_resource" "add_dns_entry" {
 count = "${data.external.check_dns_input.result.value}" ? 1 : 0
   connection {
     type = "ssh"
     host = "192.168.122.104"
     user = var.user
     private_key = "${file("~/.ssh/id_rsa")}"
   }
  provisioner "remote-exec" {
    inline = [
            "echo  \"${data.template_file.dns_reverse[count.index].rendered}\" | sudo tee -a /etc/bind/reverse.lizy", 
            "echo  \"${data.template_file.dns_forward[count.index].rendered}\" | sudo tee -a /etc/bind/forward.lizy", 
            "sudo systemctl restart bind9.service",
      ]
    }
 }
#------------------------------------------------------------------
output "list_disk" {
value = null_resource.disk_mappings.*.triggers
}
output "vm_info" {
value = "${data.external.get_info_ip.result}"
}
