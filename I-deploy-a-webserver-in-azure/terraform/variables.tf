variable "prefix" {
  description = "The prefix used for all resources"
  default = "my-webserver"
}

variable "location" {
  description = "The Azure Region in which all resources are created."
  default = "westeurope"
}

variable "instance_count" {
  description = "The count of instances to create."
  default = 2
}

variable "vm_id" {
  description = "The id of the custom image deployed by packer."
  default = "/subscriptions/07e48976-c9d2-4cb8-9116-89999b276e95/resourceGroups/packer-rg/providers/Microsoft.Compute/images/grayfox-ubuntu18.04"
}

variable "vm_size" {
  description = "The size of the VM's."
  default = "Standard_F2"
}

variable "vm_disk_type" {
  description = "The os disk type for the vms"
  default = "Standard_LRS"
}

variable "vm_user" {
  description = "The username for login to the vm instance"
  default = "adminuser"
}

variable "vm_password" {
  description = "The password for login to the vm instance"
  default = "v3r4S3cur3_@c$1298"
}
