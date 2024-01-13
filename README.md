# Terraform

Vous avez engagé une équipe d'expert  pour mettre en place un environnement de plusieurs serveurs.  Le budget étant limité, vos experts reportent la création du plan de reprise d'activité à une autre fois. ils vous proposent  une solution de sauvegarde des données de votre activité, qui permettrons avec un délais de reconstituer votre infrastruture en cas de sinistre.

Une année après le démarrage de votre activité, vous souhaitez augmenter la résilience de votre infrastructure  avec la mise en place d'un plan de reprise d'activité ayant un RTO ( Recovery Time Objectif) faible.

En reponse à votre demande, l'équipe vous **facture** la création d'une autre infrastruture, identique à l'existant, dans un autre centre de données.

# Qu'est ce que terraform

Terraform est un outils permettant de concevoir  une infrastructure dematérialisée pouvant être déployer à l'identique sur un materiel choisi.  Il  améliore le temps de conception d'une infrastructure et optimise les couts.

L'exemple suivant  aborde l'écriture du code terraform pour la création d'une machine virtuelle sur l'hyperviseur KVM (libvirt)

# KVM kernel virtual Machine

KVM est un hyperviseur de type 1, disponible sur les distributions linux sous la forme d'une application native. Vous pouvez l'installer et l'utiliser  si vous disposer des ressources ( RAM, CPU et Disques) necessaires. En effet une machine  virtuelle est une emmulation d'une machine physique. Elle partage les ressources de la machine physique en plusieurs machines virtuelles.  La suite de cet exemple suppose que vous disposez d'un hôte KVM fonctionnelle.

# Machine virtuelle

1. Initialisation du projet

   /opt/projet/terraform/vm/main.tf

   ```
   terraform {
     required_version = "> 0.8.0"
       required_providers {
       libvirt = {
         source = "dmacvicar/libvirt" 
       }
     }
   }

   provider "libvirt" {
     uri = "qemu:///system"
   }
   ```
2. Déclarations des variables
   /opt/projet/terraform/vm/variables.tf

   ```
   variable vm_name_1         {
                     description = "nom de la machine"
   }
   variable vm_disk           {
                     description = "tous les diques de la machine virtuelle" 
   }
   variable vm_memory         {
                     description = "la mémoire ram alloué à la machine virtuelle"
   }
   variable vm_vcpu           {
                     description = "vcpu"
   }   
   variable vm_network        {
                     description = "nom du réseau privée"
   }
   variable vm_disk_source   {
                     description = "nom et version de la distribution linux"
   }
   variable vm_disk_size     {
                     description = "la taille du disque à créer"
   }
   variable bastion_host      {
                     description = "adresse du bastion"
   }
   variable bastion_user      {
                     description = "user bastion"
   }
   variable pubkey            {
                     description = "la clé publique à installer dans la machine virtuelle"
   }
   ```

   Initialisation des variables
   /opt/projet/terraform/vm/inputs.tfvars

   ```
   vm_name_1         = "k8s-master" 
   vm_memory         = 4096
   vm_vcpu           = 4
   vm_network        = "private"
   vm_disk_size      = 10737418240
   vm_disk           = ""
   bastion_host      = "routeur"
   bastion_user      = "user"
   user              = "user"
   pubkey            = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILV/wDRUQ+k3jHx15kc4b8hSY8Xhurp44OM2oHHO3a8C your_email@example.com"
   ```
3. fichier de création de la machine
   /opt/projet/terraform/vm/vm.tf

   ```
   #déclaration du disque de notre vm
   module disk1_node1 {
   source = "../modules/virtual_machine_disk/"
   vm_disk_name = var.vm_name_1
   vm_disk_source = var.vm_disk_source
   vm_disk_size = var.vm_disk_size
   }

   # déclarartion de notre machine virtuelle
   module k8s-master {
   source         = "../modules/virtual_machine/"
   vm_name        = var.vm_name_1
   vm_disk        = [ module.disk1_node1.vm_disk_id ]
   vm_memory      = var.vm_memory
   vm_network     = var.vm_network
   vm_vcpu        = var.vm_vcpu
   bastion_host   = var.bastion_host
   bastion_user   = var.bastion_user
   user           = var.user
   host_password  = var.host_password
   pubkey         = var.pubkey
   destination    = var.destination
   }


   ```
4. Matérialisation de la machine virtuelle

   ```
   terraform init  -var-file=inputs.tfvars
   terraform aaply -var-file=inputs.tfvars
   ```

Il y'a quatre fichiers dans notre dossier pour la création de la machine virtuelle

* déclarartion du provider utilisé : main.tf
* déclaration des variables : variables.tf
* initialisation des variables
* instantiation de la création de la machine virtuelle en utilisant les données fournies et les modules disponibles
