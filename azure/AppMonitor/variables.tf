variable "subscription" {
  type        = string
  description = "The subscription related to the CIS Development"
}

variable "resource_group_name" {
  type        = string
  description = "The App & Monitor resource group name"
}

variable "resource_group_id" {
  type        = string
  description = "The App & Monitor resource group id"
}

variable "location" {
  type        = string
  description = "The App & Monitor location"
}

variable "scope_publicIP" {
  type        = string
  description = "The scope of the security-logalert5"
}

variable "scope_sqlserver" {
  type        = string
  description = "The scope of the security-logalert8 related to the sql server"
}

variable "location-westEU" {
  type        = string
  description = "The App & Monitor location in west europe"
}

variable "email_address" {
  type        = string
  description = "The email related to the action group"
}



