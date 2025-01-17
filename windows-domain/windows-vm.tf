
# OS Image 


# Windows Server 2022 SKU used to build VMs
variable "windows_2022_sku" {
  type        = string
  description = "Windows Server 2022 SKU used to build VMs"
  default     = "2022-Datacenter"
}

# Windows Server 2019 SKU used to build VMs
variable "windows_2019_sku" {
  type        = string
  description = "Windows Server 2019 SKU used to build VMs"
  default     = "2019-Datacenter"
  #default = "cis-ws2019-l1"
}

# Windows Server 2016 SKU used to build VMs
variable "windows_2016_sku" {
  type        = string
  description = "Windows Server 2016 SKU used to build VMs"
  default     = "2016-Datacenter"
}


