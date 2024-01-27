## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > 0.8.0 |
| <a name="requirement_fastapi"></a> [fastapi](#requirement\_fastapi) | > 3.7 |
| <a name="requirement_libguestfs"></a> [libguestfs](#requirement\_libguestfs) | > 1.48 |
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | > 0.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_libvirt"></a> [libvirt](#provider\_libvirt) | n/a |

## Modules


| Name                                                                    | Source                                | Version |
| ----------------------------------------------------------------------- | ------------------------------------- | ------- |
| <a name="module_airflow2"></a> [airflow2](#module\_airflow2)            | ../modules/virtual_machine/disk5/v0.2 | n/a     |
| <a name="module_disk1_node1"></a> [disk1\_node1](#module\_disk1\_node1) | ../modules/virtual_machine_disk/v0.1  | n/a     |

## Inputs


| Name                                                                                | Description                                  | Type     | Default | Required |
| ----------------------------------------------------------------------------------- | -------------------------------------------- | -------- | ------- | :------: |
| <a name="input_bastion_host"></a> [bastion\_host](#input\_bastion\_host)            | adresse du serveur de rebond                 | string   | n/a     |   yes   |
| <a name="input_bastion_user"></a> [bastion\_user](#input\_bastion\_user)            | utilisateur serveur de rebond                | `string` | n/a     |   yes   |
| <a name="input_pubkey"></a> [pubkey](#input\_pubkey)                                | ssh guest publique key                       | `string` | n/a     |   yes   |
| <a name="input_vm_disk"></a> [vm\_disk](#input\_vm\_disk)                           | liste des disques pour une machine virtuelle | `list`   | n/a     |   yes   |
| <a name="input_vm_disk1_source"></a> [vm\_disk1\_source](#input\_vm\_disk1\_source) | nom de la distribution 'debian12'            | `string` | n/a     |   yes   |
| <a name="input_vm_disk_size"></a> [vm\_disk\_size](#input\_vm\_disk\_size)          | taille du disque                             | `number` | n/a     |   yes   |
| <a name="input_vm_memory"></a> [vm\_memory](#input\_vm\_memory)                     | capacité de la mémoire                     | `string` | n/a     |   yes   |
| <a name="input_vm_name_1"></a> [vm\_name\_1](#input\_vm\_name\_1)                   | nom de la machine virtuelle                  | `string` | n/a     |   yes   |
| <a name="input_vm_network"></a> [vm\_network](#input\_vm\_network)                  | nom de réseau                               | `string` | n/a     |   yes   |
| <a name="input_vm_vcpu"></a> [vm\_vcpu](#input\_vm\_vcpu)                           | nombre de vcpu                               | `number` | n/a     |   yes   |

## Outputs


| Name                                                                          | Description                   |
| ----------------------------------------------------------------------------- | ----------------------------- |
| <a name="output_airflow_ip"></a> [airflow\_ip](#output\_airflow\_ip)          | adresse ip serveur airflow    |
