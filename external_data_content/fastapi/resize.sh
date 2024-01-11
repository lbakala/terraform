#!/bin/bash
vm_name=$( echo ${2} | cut -d"/" -f5 | cut -d"." -f1)
sudo virt-resize --expand /dev/sda2 ${1} ${2}
