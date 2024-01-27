variable vm_name_1 {
  type = string
  description = "nom de la machine virtuelle"
}

variable vm_name_2 {
  type = string
  description = "nom de la machine virtuelle"
}

variable vm_disk {
  type = list
  description = "liste des disques pour une machine virtuelle"
}

variable vm_memory         {
  type = string
  description = "capacité de la mémoire"
}

variable vm_vcpu {
  type = number
  description = "nombre de vcpu"

}

variable vm_network { 
  type = string
  description = "nom de réseau"
}

variable vm_disk1_source   {
  type = string
  description = "nom de la distribution 'debian12'"
}

variable vm_disk_size {
  type = number
  description = "taille du disque"
}

variable bastion_host {
  type = string
  description = "adresse du serveur de rebond"
}

variable bastion_user {
  type = string
  description = "utilisateur serveur de rebond"
}

variable pubkey {
  type = string
  description = "ssh guest publique key"
}

module disk1_node1 {
source = "../modules/virtual_machine_disk/v0.1"
vm_disk_name = var.vm_name_1
vm_disk_source = "debian12"
vm_disk_size = 10737418240
}

module airflow2 {
source         = "../modules/virtual_machine/disk5/v0.2"
vm_name        = var.vm_name_1
vm_disk        = [ module.disk1_node1.vm_disk_id ]
vm_memory      = var.vm_memory
vm_network     = var.vm_network
vm_vcpu        = var.vm_vcpu
bastion_host   = var.bastion_host
bastion_user   = var.bastion_user
pubkey         = var.pubkey
}


module disk1_node2 {
source = "../modules/virtual_machine_disk/v0.1"
vm_disk_name = var.vm_name_2
vm_disk_source = var.vm_disk1_source
vm_disk_size = var.vm_disk_size
}

module controller {
source         = "../modules/virtual_machine/disk5/v0.2"
vm_name        = var.vm_name_2
vm_disk        = [ module.disk1_node2.vm_disk_id ]
vm_memory      = var.vm_memory
vm_network     = var.vm_network
vm_vcpu        = var.vm_vcpu
bastion_host   = var.bastion_host
bastion_user   = var.bastion_user
pubkey         = var.pubkey
}

output "airflow_ip" {
  value = module.airflow2.ipAddress 
  description = "adresse ip serveur airflow"
}
output "controller_ip" {
  value = module.controller.ipAddress 
  description = "adresse ip serveur controller"
}

