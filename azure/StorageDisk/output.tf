output "disk-tenant-id" {
  value = azurerm_disk_encryption_set.security-disk-set1.identity.0.tenant_id
}

output "disk-principal-id" {
  value = azurerm_disk_encryption_set.security-disk-set1.identity.0.principal_id
}

output "storage-endpoint" {
  value = azurerm_storage_account.security-storageaccount-2.primary_blob_endpoint
}

output "storage-access-key" {
  value = azurerm_storage_account.security-storageaccount-2.primary_access_key
}

output "storage-account-name1" {
  value = azurerm_storage_account.security-storageaccount-1.name
}

output "storage-account-name2" {
  value = azurerm_storage_account.security-storageaccount-2.name
}

output "disk-encryption-set1" {
  value = azurerm_disk_encryption_set.security-disk-set1.id
}

output "storage1_account_primary_access_key" {
  //value = data.azurerm_storage_account.example.primary_access_key
  //sensitive = true
  value = nonsensitive(azurerm_storage_account.security-storageaccount-1.primary_access_key)
}

output "storage2_account_primary_access_key" {
  //sensitive = true
  value = nonsensitive(azurerm_storage_account.security-storageaccount-2.primary_access_key)
}
