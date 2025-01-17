variable "Linux_VM_name" {
  type        = string
  description = "The name of the Linux Virtual Machine"
}

variable "size" {
  type        = string
  description = "The size of the Linux vm"
}

variable "resource_group_name" {
  type        = string
  description = "The VM resource group name"
}

variable "location" {
  type        = string
  description = "The VM location"
}

variable "disk-encryption-set1-id" {
  type        = string
  description = "The id of the disk encryption set in StorageDisk Module"
}
