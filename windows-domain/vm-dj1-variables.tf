
# AD dj1 Virtual Machine - Variables 


# Azure virtual machine settings #

variable "dj1_vm_size" {
  type        = string
  description = "Size (SKU) of the virtual machine to create"
  default     = "Standard_B2s"
}

variable "dj1_license_type" {
  type        = string
  description = "Specifies the BYOL type for the virtual machine. Possible values are 'Windows_Client' and 'Windows_Server' if set"
  default     = null
}

# Azure virtual machine storage settings #

variable "dj1_delete_os_disk_on_termination" {
  type        = string
  description = "Should the OS Disk (either the Managed Disk / VHD Blob) be deleted when the Virtual Machine is destroyed?"
  default     = "true" # Update for your environment
}

variable "dj1_delete_data_disks_on_termination" {
  description = "Should the Data Disks (either the Managed Disks / VHD Blobs) be deleted when the Virtual Machine is destroyed?"
  type        = string
  default     = "true" # Update for your environment
}

# Active Directory Configuration #

# domain controller 2 name
variable "ad_dj1_name" {
  type        = string
  description = "This variable defines the name of AD Domain Controller 2"
}

# domain controller 1 private ip address
variable "ad_dj1_ip_address" {
  type        = string
  description = "This variable defines the private ip address of AD Domain Controller 2"
}
