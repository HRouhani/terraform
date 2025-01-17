output "linux-key-id" {
  value = azurerm_key_vault_key.security-kv-key-linux.id
}

output "key-vault-id" {
  value = azurerm_key_vault.security-kv.id
}

output "key_vault_name" {
  value = azurerm_key_vault.security-kv.name
}