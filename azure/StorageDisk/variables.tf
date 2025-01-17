variable "subscription" {
  type        = string
  description = "The subscription related to the CIS Development"
}

variable "resource_group_name" {
  type        = string
  description = "The Storage & Disks resource group name"
}

variable "location" {
  type        = string
  description = "The Storage & Disks location"
}

variable "location2" {
  type        = string
  description = "The StorageAccount2 location"
}

variable "linux-key-id" {
  type        = string
  description = "The linux key id"
}


variable "key-vault-id" {
  type        = string
  description = "The id of the KeyVault creaed in KeyVault Module"
}

