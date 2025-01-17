variable "subscription" {
  type        = string
  description = "The subscription related to the CIS Development"
}

variable "resource_group_name" {
  type        = string
  description = "The DataBases resource group name"
}

variable "location" {
  type        = string
  description = "The DataBases location"
}

variable "storage-endpoint" {
  type        = string
  description = "The storageaccount-2 primary blob endpoint"
}

variable "storage-access-key" {
  type        = string
  description = "The storageaccount-2 primary access key"
}

variable "storage-account-name2" {
  type        = string
  description = "The name of the security-storageaccount-2"
}

variable "key-vault-id" {
  type        = string
  description = "The id of the KeyVault creaed in KeyVault Module"
}

variable "administrator_login" {
  type        = string
  description = "The Username has been used for several databases"
}

variable "administrator_login_password" {
  type        = string
  description = "The Password has been used for several databases"
}

variable "login_username_mssql" {
  type        = string
  description = "The login Username for MSSQL server, handle by ActiveDirectory"
}

variable "object_id_mssql" {
  type        = string
  description = "The Object ID related to the Login Username in MSSQL"
}

variable "emails" {
  type        = string
  description = "The email related to the mssql VA"
}
