# Terraform
création des machines virtuelles pour kubernetes

Terraform est l'un des outils indispensables pour le provisionning des briques nécessaires à la mise en place d'une infrastructure. Il est très facile à apprehender et permet de créer une infrastructure rapidement sans requérir la présence d'un architect. C'est comme une boite de conserve : elle ne nécessite pas des connaisances en cuisine pour être consommé.

L'architect a mené une reflexion et a construit une infrastructure as a code prêt à l'emploi pour repondre à un besoin.

Ici, le code permet de :
1. Créer 3 machines virtuelles sur KVM
2. Créer un utilisateur user
3. Installer la clé publique SSH pour user
4. Désactiver IPV6
5. Ajouter la configuration ssh de chaque machine dans /etc/ssh/ssh_config.d/
6. Réserver l'ip attribuer dans le serveur DHCP
7. Assigner le nom DNS dans le serveur BIN9

## 1 - Configuration des machines
      memory: 4GB
      vcpu: 4
      disk_system: 10GB
      disk_data: 10GB
      Network: private
## 2 - Initialisation des machines
Elle se fait dans deux fichiers situés à la racine du projet.

      inputs.tf_vars : contenant les variables initialisées
      vm.tf          : contenant la constitution de chaque machine

      Demande:
      J'ai besoin d'une VM nommée: k8s_master, ayant 4GB de RAM, 4VCPU sur le réseau "network".
      Avec deux disques: 10GB et 10GB
      L'acces à la VM est possible en passant par un bastion (host + user + public key auth)
 
      Reponse:
      vm_name_1         = "k8s-master" 
      vm_name_2         = "k8s-node-1" 
      vm_name_3         = "k8s-node-2" 
      vm_memory         = 4096
      vm_vcpu           = 4
      vm_network        = "network"
      vm_disk1_source   = "/opt/storage/template/template-4x-no-swap.qcow2"
      vm_disk2_size     = 10737418240
      vm_disk           = ""
      
      bastion_host      = "routeur"
      bastion_user      = "user"
      user              = "user"
      #host_password     = "xxxxxx" A déclarer au niveau system"export TF_VAR_host_password=xxxxx"
      pubkey            = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWpdWKPH5rlFD47KTYkMz/...."
      destination       = "/home/user/.ssh/authorized_keys"

            
      
  



