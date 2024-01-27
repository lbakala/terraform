terraform {
  #required_version = "> 0.8.0"
    required_providers {
    libvirt = {
      source = "dmacvicar/libvirt" 
      #version = "0.7.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

