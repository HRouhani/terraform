output "public_ip_address" {
  value = azurerm_linux_virtual_machine.security-vm-linux.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.linux_vm_ssh.private_key_pem
  sensitive = true
}

output "linux_admin_username" {
  value = azurerm_linux_virtual_machine.security-vm-linux.admin_username
}


output "summary" {
  value = <<EOT
Please execute the following terraform command to get the private ssh key

terraform output -raw tls_private_key > id_rsa

chmod 600 id_rsa

ssh -o StrictHostKeyChecking=no ${azurerm_linux_virtual_machine.security-vm-linux.admin_username}@${azurerm_linux_virtual_machine.security-vm-linux.public_ip_address} -i ./id_rsa
EOT
}

# to be used in the monitor alert related part in the scope
output "public-ip" {
  value = azurerm_public_ip.security-ip.id
}
