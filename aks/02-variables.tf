# Azure Location
variable "location" {
  type        = string
  description = "Azure Region where all these resources will be provisioned"
  default     = "Germany West Central"
}

# Azure Resource Group Name
variable "resource_group_name" {
  type        = string
  description = "This variable defines the Resource Group"
  #default = "terraform-aks"
  default = "Security-Team-rg-AKS"
}

# Azure AKS Environment Name
variable "environment" {
  type        = string
  description = "This variable defines the Environment"
  default     = "sec"
}


variable "subscription" {
  type        = string
  description = "The subscription related to the CIS Development"
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  #default     = 3
  default = 1
}



# AKS Input Variables

# SSH Public Key for Linux VMs
variable "ssh_public_key" {
  #default = "~/.ssh/aks-prod-sshkeys-terraform/aksprodsshkey.pub"
  default = "id_rsa.pub"
  #default = "${path.cwd}/id_rsa.pub"
  description = "This variable defines the SSH Public Key for Linux k8s Worker nodes"
}

# Windows Admin Username for k8s worker nodes
variable "windows_admin_username" {
  type        = string
  default     = "azureuser"
  description = "This variable defines the Windows admin username k8s Worker nodes"
}

# Windows Admin Password for k8s worker nodes
variable "windows_admin_password" {
  type        = string
  default     = "StackSimplify@102" # Updated June 2023
  description = "This variable defines the Windows admin password k8s Worker nodes"
}

