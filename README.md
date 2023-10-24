# Terraform
création des machines virtuelles pour kubernetes

Terraform est l'un des outils indispensables pour le provisionning des briques nécessaires à la mise en place d'une infrastructure. Il est très facile à apprehender et permet de créer une infrastructure rapidement sans requérir la présence d'un architect. C'est comme une boite de conserve : elle ne nécessite pas des connaisances en cuisine pour être consommé.

L'architect a mené une reflexion et a construit une infrastructure as a code prêt à l'emploi pour repondre à un besoin.

Ici, le code permet de créer :
      - 3 machines virtuelles sur KVM
      - Créer un utilisateur user
      - Installer la clé publique SSH pour user
      - Désactiver IPV6
      - Ajouter la configuration ssh permettant de se connecter à chacune des machines via un bastion, dans /etc/ssh/ssh_config.d/
      - Réserver l'ip attribuer dans le serveur DHCP
      - Assigner le nom DNS dans le serveur BIN9

  



