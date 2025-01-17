# the sql server name to be used in the monitor alert part in scope
output "sql-server" {
  value = azurerm_mssql_server.security-sql-server-1.id
}

output "storage-account-name3" {
  value = azurerm_storage_account.security-storageaccount-3.name
}

output "storage3_account_primary_access_key" {
  //value = data.azurerm_storage_account.example.primary_access_key
  //sensitive = true
  value = nonsensitive(azurerm_storage_account.security-storageaccount-3.primary_access_key)
}
