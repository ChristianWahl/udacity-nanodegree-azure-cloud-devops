variable "prefix" {
  description = "The prefix which should be used for all resources"
  default = "my-webserver"
}

variable "location" {
  description = "The Azure Region in which all resources should be created."
  default = "westeurope"
}

variable "instance_count" {
  description = "The amount of instances to create."
  default = 1
}

variable "vm_id" {
  description = "The id of an image deployed by packer."
  default = "/subscriptions/07e48976-c9d2-4cb8-9116-89999b276e95/resourceGroups/packer-rg/providers/Microsoft.Compute/images/grayfox-ubuntu18.04"
}