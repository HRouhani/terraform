# Active Directory 

# Locals
locals {
  dns_dc_servers = [var.ad_dc1_ip_address]
  dc_servers     = [var.ad_dc1_ip_address]

  dns_dj_servers = [var.ad_dj1_ip_address]
  dj_servers     = [var.ad_dj1_ip_address]

}

output "ad_domain_controllers_list_ip_address" {
  description = "List of Domain Controller IP Address"
  value       = var.ad_dc1_ip_address
}

output "ad_domain_controllers_count" {
  description = "Number of Domain Controllers"
  value       = 1
}

output "ad_domain_joined_list_ip_address" {
  description = "List of Domain Joined IP Address"
  value       = var.ad_dj1_ip_address
}

output "ad_domain_joined_servers_count" {
  description = "Number of Domain Joined servers"
  value       = 1
}
