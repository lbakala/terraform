# Terraform

Vs avez engage une équipe d'expert  pour mettre en place un environnement de plusieurs serveurs.  Le budget étant limité, vos experts reportent la création du plan de reprise d'activité à une autre fois. ils vous proposent  une solution de sauvegarde des données de votre activité, qui permettrons avec un délais de reconstituer votre infrastruture en cas de sinistre.

Une année après le démarrage de votre activité, vous souhaitez augmenter la résilience de votre infrastructure  avec la mise en place d'un plan de reprise d'activité ayant un RTO ( Recovery Time Objectif) faible.

En reponse à votre demande, l'équipe vous **facture** la création d'une autre infrastruture, identique à l'existant, dans un autre centre de données.

# Qu'est ce que terraform

Terraform est un outils permettant de concevoir  une infrastructure dematérialisée pouvant être déployer à l'identique sur un materiel choisi.  Il  améliore le temps de conception d'une infrastructure et optimise les couts.

L'exemple suivant  aborde l'écriture du code terraform pour la création d'une machine virtuelle sur l'hyperviseur KVM (libvirt)

# KVM kernel virtual Machine

KVM est un hyperviseur de type 1, disponible sur les distributions linux sous la forme d'une application native. Vous pouvez l'installer et l'utiliser  si vous disposer des ressources ( RAM, CPU et Disques) necessaires. En effet une machine  virtuelle est une emmulation d'une machine physique. Elle partage les ressources de la machine physique en plusieurs machines virtuelles.  La suite de cet exemple suppose que vous disposez d'un hôte KVM fonctionnelle.

# Machine virtuelle

```
Configuration
Adresse de l'hôte: 192.168.122.1/24
Server DHCP & DNS :  192.168.122.104/24 + 172.16.0.254/16
```



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
