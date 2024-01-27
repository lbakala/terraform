variable "vm_name" { 
  type = string
  description = "virtual machine name"
  }

variable "vm_memory" { 
  type = string
  description = "virtual machine memory"
  }

variable "vm_vcpu"  { 
  type = string
  description = "virtual machine vcpu"
  }

variable "vm_network" { 
  type = string
  description = "virtual machine name" 
  }

variable "vm_network_mac" { 
  type = string
  description = "network guest mc addr"
  default     = "" 
}

variable "pubkey" { 
  type     = string
  description = "ssh publique key guest"
  default     = "" 
}

variable "vm_disk" {
  type = list
  description = "liste des disques attendus"
  }

variable "bastion_host" { 
  type     = string
  description = "hostname serveur de rebond"
  default     = ""
}

variable "bastion_user" {
  default     = "" 
  description = "bastion serveur de rebond: user"
}

#------------------------------------------------------------------
resource "null_resource" "disk_mappings" {
  count = "${length(var.vm_disk)}"
  triggers = {
    volume_id = "${element(var.vm_disk, count.index)}"
  }
}
#------------------------------------------------------------------
resource "libvirt_domain" "virtual_machine" {
  name   = var.vm_name
  memory = var.vm_memory
  vcpu   = var.vm_vcpu
  #running = false
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
resource "null_resource" "local_creation" {
    triggers = {
    disk1 = "${null_resource.disk_mappings[0].triggers.volume_id}"
    disk2 = replace("${null_resource.disk_mappings[0].triggers.volume_id}","${var.vm_name}","unknow-${var.vm_name}")
    pub_key = var.pubkey
    #always_run = "${timestamp()}"
  }
   provisioner "local-exec" {
    when = create
    command = "curl -s -X POST http://localhost:8000/growfs/ -H 'Content-Type: application/json' -d '{\"old_disk\":\"${self.triggers.disk2}\", \"new_disk\":\"${self.triggers.disk1}\", \"pub_key\":\"${self.triggers.pub_key}\"}' > ${self.id}.txt"
  }
  depends_on = [libvirt_domain.virtual_machine]
}
#------------------------------------------------------------------
data "template_file" "getIp" {
  template = file("${null_resource.local_creation.id}.txt")
}
#------------------------------------------------------------------
data "template_file" "JumpHost" {
template = file("${path.module}/templates/jumphost.tpl")
  vars = {
    short_host = "${var.vm_name}"
    ip         =  jsondecode(data.template_file.getIp.rendered)["ipAddress"]
    bastion    = var.bastion_host
  }
}
#------------------------------------------------------------------
resource "null_resource" "local" {
  triggers = {
  template = "${data.template_file.JumpHost.rendered}"
  #always_run = "${timestamp()}"
   }
   provisioner "local-exec" {
    command = "echo  \"${data.template_file.JumpHost.rendered}\" > /etc/ssh/ssh_config.d/${var.vm_name}.conf"
  }
  depends_on = [null_resource.local_creation]
}
#------------------------------------------------------------------
resource "null_resource" "local_remove" {
    triggers = {
    server_name = var.vm_name
  }
   provisioner "local-exec" {
    when = destroy
    command = "curl -s -X POST http://localhost:8000/destroy/ -H 'Content-Type: application/json' -d '{\"machine\":\"${self.triggers.server_name}\"}'"
  }
}
#------------------------------------------------------------------
output "ipAddress" {
value =jsondecode(file("${null_resource.local_creation.id}.txt"))["ipAddress"]
}
