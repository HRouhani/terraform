variable "subscription" {
  type        = string
  description = "The subscription related to the CIS Development"
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
  description = "The email being used in both AppMonitor & Databases Modules"
}

