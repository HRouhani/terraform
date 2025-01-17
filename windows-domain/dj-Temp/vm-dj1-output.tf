# AD dj1 Virtual Machine - Output 

output "ad_dj1_vm_name" {
  description = "Domain Joined 1 Machine name"
  value       = azurerm_windows_virtual_machine.dj1-vm.name
}

output "ad_dj1_vm_ip_address" {
  description = "Domain Joined 1 IP Address"
  value       = azurerm_public_ip.dj1-eip.ip_address
}


