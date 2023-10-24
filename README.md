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

