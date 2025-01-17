output "public_ip_address" {
  value = module.VM.public_ip_address
}

output "tls_private_key" {
  value     = module.VM.tls_private_key
  sensitive = true
}

output "summary" {
  //sensitive = true
  value = <<EOT
Please execute the following terraform command to get the private ssh key (Only if Port 22 is Open on VM, by default NOT!)

terraform output -raw tls_private_key > id_rsa

chmod 600 id_rsa

ssh -o StrictHostKeyChecking=no ${module.VM.linux_admin_username}@${module.VM.public_ip_address} -i ./id_rsa


following commands need to be run manually for each storageAccount, to make 2 Tests Green: (not possible in Terraform)

# storageaccount 1
az storage logging update --account-name ${module.StorageDisk.storage-account-name1} --account-key ${module.StorageDisk.storage1_account_primary_access_key}  --services b --log rwd --retention 90
az storage logging update --account-name ${module.StorageDisk.storage-account-name1} --account-key ${module.StorageDisk.storage1_account_primary_access_key} --services t --log rwd --retention 90


# storageaccount 2
az storage logging update --account-name ${module.StorageDisk.storage-account-name2} --account-key ${module.StorageDisk.storage2_account_primary_access_key}  --services b --log rwd --retention 90
az storage logging update --account-name ${module.StorageDisk.storage-account-name2} --account-key ${module.StorageDisk.storage2_account_primary_access_key} --services t --log rwd --retention 90


# storageaccount 3
az storage logging update --account-name ${module.DataBases.storage-account-name3} --account-key ${module.DataBases.storage3_account_primary_access_key}  --services b --log rwd --retention 90
az storage logging update --account-name ${module.DataBases.storage-account-name3} --account-key ${module.DataBases.storage3_account_primary_access_key} --services t --log rwd --retention 90

# Ensure Cross Tenant Replication is not enabled for storage accounts (run the following command manually for each storage account):

az storage account update --name ${module.StorageDisk.storage-account-name1} --resource-group ${azurerm_resource_group.security-rg.name} --allow-cross-tenant-replication false
az storage account update --name ${module.StorageDisk.storage-account-name2} --resource-group ${azurerm_resource_group.security-rg.name} --allow-cross-tenant-replication false
az storage account update --name ${module.DataBases.storage-account-name3} --resource-group ${azurerm_resource_group.security-rg.name} --allow-cross-tenant-replication false

# Enable automatic key rotation for Key Vault keys (run these commands manually): Make sure you change first the Access Config in KeyVault to Azure role-based access control
az keyvault key rotation-policy update --vault-name "${module.KeyVault.key_vault_name}" --name "Security-Team-kv-sql-key1" --value @rotation-policy.json
az keyvault key rotation-policy update --vault-name "${module.KeyVault.key_vault_name}" --name "Security-Team-kv-vm-linux" --value @rotation-policy.json
az keyvault key rotation-policy update --vault-name "${module.KeyVault.key_vault_name}" --name "Security-Team-kv-mssql" --value @rotation-policy.json
az keyvault key rotation-policy update --vault-name "${module.KeyVault.key_vault_name}" --name "Security-Team-kv-activitylog-key2" --value @rotation-policy.json
az keyvault key rotation-policy update --vault-name "${module.KeyVault.key_vault_name}" --name "Security-Team-kv-activitylog-key" --value @rotation-policy.json


EOT
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}
