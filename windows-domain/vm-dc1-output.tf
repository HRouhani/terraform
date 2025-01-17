
# AD DC1 Virtual Machine - Output 


output "ad_dc1_vm_name" {
  description = "Domain Controller 1 Machine name"
  value       = azurerm_windows_virtual_machine.dc1-vm.name
}

output "ad_dc1_vm_ip_address" {
  description = "Domain Controller 1 IP Address"
  value       = azurerm_public_ip.dc1-eip.ip_address
}

