variable vm_name_1         {}
variable vm_name_2         {}
variable vm_name_3         {}
variable vm_disk           {}
variable vm_memory         {}
variable vm_vcpu           {}   
variable vm_network        {}
variable vm_disk1_source   {}
variable vm_disk2_size     {}
variable bastion_host      {}
variable bastion_user      {}
variable user              {}
variable pubkey            {}

#---

module disk1_node1 {
source = "./modules/virtual_machine_disk"
vm_disk_name = var.vm_name_1
vm_disk_source = var.vm_disk1_source
}

module disk2_node1 {
source = "./modules/virtual_machine_disk"
vm_disk_name = "${var.vm_name_1}v2"
vm_disk_size = var.vm_disk2_size
}

module disk1_node2 {
source = "./modules/virtual_machine_disk"
vm_disk_name = var.vm_name_2
vm_disk_source = var.vm_disk1_source
}

module disk2_node2 {
source = "./modules/virtual_machine_disk"
vm_disk_name = "${var.vm_name_2}v2"
vm_disk_size = var.vm_disk2_size
}

module disk1_node3 {
source = "./modules/virtual_machine_disk"
vm_disk_name = var.vm_name_3
vm_disk_source = var.vm_disk1_source
}

module disk2_node3 {
source = "./modules/virtual_machine_disk"
vm_disk_name = "${var.vm_name_3}v2"
vm_disk_size = var.vm_disk2_size
}

module k8s-master {
source         = "./modules/virtual_machine"
vm_name        = var.vm_name_1
vm_disk        = [ module.disk1_node1.vm_disk_id ]
vm_memory      = var.vm_memory
vm_network     = var.vm_network
vm_vcpu        = var.vm_vcpu
bastion_host   = var.bastion_host
bastion_user   = var.bastion_user
user           = var.user
pubkey         = var.pubkey
}

module k8s-node-1 {
source         = "./modules/virtual_machine"
vm_name        = var.vm_name_2
vm_disk        = [ module.disk1_node2.vm_disk_id, module.disk2_node2.vm_disk_id ]
vm_memory      = var.vm_memory
vm_network     = var.vm_network
vm_vcpu        = var.vm_vcpu
bastion_host   = var.bastion_host
bastion_user   = var.bastion_user
user           = var.user
pubkey         = var.pubkey
}

module k8s-node-2 {
source         = "./modules/virtual_machine"
vm_name        = var.vm_name_3
vm_disk        = [ module.disk1_node3.vm_disk_id, module.disk2_node3.vm_disk_id]
vm_memory      = var.vm_memory
vm_network     = var.vm_network
vm_vcpu        = var.vm_vcpu
bastion_host   = var.bastion_host
bastion_user   = var.bastion_user
user           = var.user
pubkey         = var.pubkey
}

#---
output "k8s-mater_ip"  { value = module.k8s-master.vm_info }
output "k8s-node-1_ip" { value = module.k8s-node-1.vm_info }
output "k8s-node-2_ip" { value = module.k8s-node-2.vm_info }

