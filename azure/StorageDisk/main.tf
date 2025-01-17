resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# creating Storage Account
resource "azurerm_storage_account" "security-storageaccount-1" {
  name                     = "securityteam1${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
  # related to secure transfer enabled
  queue_encryption_key_type = "Account"
  table_encryption_key_type = "Account"
  # both related to Ensure that 'Public access level' is disabled for storage accounts with blob containers (we do not use it here as we use alternative way
  # otherwise it will block all other stuff)
  # public_network_access_enabled   = false
  # allow_nested_items_to_be_public = false


  # Ensure Soft Delete is Enabled for Azure Containers and Blob Storage
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  # Ensure Storage Logging is Enabled for Queue Service for 'Read', 'Write', and 'Delete' requests
  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "sec"
  }

  infrastructure_encryption_enabled = true
}

resource "azurerm_storage_container" "activitylogs" {
  name                  = "insights-activity-logs"
  storage_account_name  = azurerm_storage_account.security-storageaccount-1.name
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.security-storageaccount-1
  ]
}

resource "azurerm_storage_container" "auditevent" {
  name                  = "insights-logs-auditevent"
  storage_account_name  = azurerm_storage_account.security-storageaccount-1.name
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.security-storageaccount-1
  ]
}

resource "azurerm_storage_container" "flowevent" {
  name                  = "insights-logs-flowevent"
  storage_account_name  = azurerm_storage_account.security-storageaccount-1.name
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.security-storageaccount-1
  ]
}

# related to Ensure Default Network Access Rule for Storage Accounts is Set to Deny 
# the related storage container need to be created before we close the access 

# and assigned the IP address of the person who runs the terraform to the ource_address_prefix
data "http" "clientip" {
  url = "https://ipv4.icanhazip.com/"
}

resource "azurerm_storage_account_network_rules" "security-storage1-networkrule" {
  storage_account_id = azurerm_storage_account.security-storageaccount-1.id
  default_action     = "Deny"
  bypass             = ["Logging", "Metrics", "AzureServices"]
  ip_rules           = ["${chomp(data.http.clientip.response_body)}"]
  # NOTE The order here matters: We cannot create storage
  # containers once the network rules are locked down

  depends_on = [
    azurerm_storage_container.activitylogs,
    azurerm_storage_container.auditevent,
    azurerm_storage_container.flowevent
  ]

}

resource "azurerm_storage_account" "security-storageaccount-2" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  name                     = "securityteam2${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location2
  # related to secure transfer enabled
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true

  # Ensure Soft Delete is Enabled for Azure Containers and Blob Storage
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  # related Ensure Storage Logging is Enabled for Queue Service for 'Read', 'Write', and 'Delete' requests 
  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "sec"
  }
  infrastructure_encryption_enabled = true

}

resource "azurerm_storage_account_network_rules" "security-storage2-networkrule" {
  storage_account_id = azurerm_storage_account.security-storageaccount-2.id

  default_action = "Deny"
  bypass         = ["Logging", "Metrics", "AzureServices"]
  ip_rules       = ["${chomp(data.http.clientip.response_body)}"]

  # NOTE The order here matters: We cannot create storage
  # containers once the network rules are locked down

}

resource "azurerm_managed_disk" "security-managed-disk1" {
  name                   = "security-team-disk-unattached-${random_string.suffix.result}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  create_option          = "Empty"
  disk_encryption_set_id = azurerm_disk_encryption_set.security-disk-set1.id
  storage_account_type   = "Standard_LRS"
  disk_size_gb           = "20"

  tags = {
    environment = "sec"
  }

  depends_on = [
    azurerm_disk_encryption_set.security-disk-set1,
    azurerm_role_assignment.disk-encryption-read-keyvault
  ]
}

resource "azurerm_disk_encryption_set" "security-disk-set1" {
  name                = "security-team-diskEncryptSet-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_key_id    = var.linux-key-id

  identity {
    type = "SystemAssigned"
  }

}


resource "azurerm_managed_disk" "security-managed-disk2" {
  name                   = "security-team-disk-linux-${random_string.suffix.result}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  create_option          = "Empty"
  disk_encryption_set_id = azurerm_disk_encryption_set.security-disk-set1.id
  storage_account_type   = "Standard_LRS"
  disk_size_gb           = "1"

  depends_on = [
    azurerm_disk_encryption_set.security-disk-set1,
    azurerm_role_assignment.disk-encryption-read-keyvault
  ]
}


### copied from KeyVault Module due to dependencies

resource "azurerm_key_vault_access_policy" "security-kv-policy-disk" {
  key_vault_id = var.key-vault-id
  tenant_id    = azurerm_disk_encryption_set.security-disk-set1.identity.0.tenant_id
  object_id    = azurerm_disk_encryption_set.security-disk-set1.identity.0.principal_id

  key_permissions = [
    "Get",
    "Create",
    "Delete",
    "Recover",
    "Purge",
    "List",
    "WrapKey",
    "UnwrapKey",
    "Update"
  ]

  secret_permissions = [
    "Get",
    "List",
  ]


  storage_permissions = [
    "Get",
  ]

}

# grant the Managed Identity of the Disk Encryption Set "Reader" access to the Key Vault
resource "azurerm_role_assignment" "disk-encryption-read-keyvault" {
  scope                = var.key-vault-id
  role_definition_name = "Reader"
  principal_id         = azurerm_disk_encryption_set.security-disk-set1.identity.0.principal_id

  depends_on = [
    azurerm_disk_encryption_set.security-disk-set1
  ]
}



# related to Ensure Storage logging is Enabled for Blob Service for 'Read', 'Write', and 'Delete' requests
# in won't make our Test Green, in spite of the fact that we do exactly what CIS propose to do. The reason is due to d fact that there is 2 Diagnostic settings for each storage
# and this one is not related to the CIS check. And there is no way to do the same for Diagnostic settings Classic from Terrarform (Only Queue one!)

resource "azurerm_log_analytics_workspace" "security-workspace3" {
  name                = "Security-Team-workspace3-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  retention_in_days   = 30

  depends_on = [
    azurerm_storage_account.security-storageaccount-1
  ]
}


locals {
  storage = ["blobServices", "tableServices", "queueServices"]
}

data "azurerm_monitor_diagnostic_categories" "security-storage1-diag" {
  for_each    = toset(local.storage)
  resource_id = "${azurerm_storage_account.security-storageaccount-1.id}/${each.key}/default/"
}


resource "azurerm_monitor_diagnostic_setting" "security-storage1-diagnostic" {
  name                       = "Security-Team-storage1-diagnostic-${random_string.suffix.result}"
  for_each                   = toset(local.storage)
  target_resource_id         = "${azurerm_storage_account.security-storageaccount-1.id}/${each.key}/default/"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.security-workspace3.id

  dynamic "log" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.security-storage1-diag[each.key].logs
    content {
      category = entry.value
      enabled  = true

      /*       retention_policy {
        enabled = true
        days    = 30
      } */
    }
  }

  dynamic "metric" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.security-storage1-diag[each.key].metrics

    content {
      category = entry.value
      enabled  = true

      /*       retention_policy {
        enabled = true
        days    = 30
      } */
    }
  }

  depends_on = [
    azurerm_log_analytics_workspace.security-workspace3
  ]
}

data "azurerm_monitor_diagnostic_categories" "security-storage2-diag" {
  for_each    = toset(local.storage)
  resource_id = "${azurerm_storage_account.security-storageaccount-2.id}/${each.key}/default/"

}

resource "azurerm_monitor_diagnostic_setting" "security-storage2-diagnostic" {
  name                       = "Security-Team-storage2-diagnostic-${random_string.suffix.result}"
  for_each                   = toset(local.storage)
  target_resource_id         = "${azurerm_storage_account.security-storageaccount-2.id}/${each.key}/default/"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.security-workspace3.id

  dynamic "log" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.security-storage2-diag[each.key].logs
    content {
      category = entry.value
      enabled  = true

      /*       retention_policy {
        enabled = true
        days    = 30
      } */
    }
  }

  dynamic "metric" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.security-storage2-diag[each.key].metrics

    content {
      category = entry.value
      enabled  = true

      /*       retention_policy {
        enabled = true
        days    = 30
      } */
    }
  }


  depends_on = [
    azurerm_log_analytics_workspace.security-workspace3
  ]
}


# this part is related to encrypt the storage accounts 1 with the key which exist in KV
# in order Object_id works, the storage should have SystemAssigned identity

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "security-kv-policy-activitylog-storage1" {
  key_vault_id = var.key-vault-id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.security-storageaccount-1.identity.0.principal_id

  key_permissions = [
    "Get",
    "Decrypt",
    "Encrypt",
    "Sign",
    "UnwrapKey",
    "Verify",
    "WrapKey",
  ]

  secret_permissions = ["Get"]

  depends_on = [
    azurerm_storage_account.security-storageaccount-1
  ]
}


resource "azurerm_key_vault_access_policy" "security-kv-policy-activitylog-storage2" {
  key_vault_id = var.key-vault-id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.security-storageaccount-2.identity.0.principal_id

  key_permissions = [
    "Get",
    "Decrypt",
    "Encrypt",
    "Sign",
    "UnwrapKey",
    "Verify",
    "WrapKey",
  ]

  secret_permissions = ["Get"]

  depends_on = [
    azurerm_storage_account.security-storageaccount-2
  ]
}

resource "azurerm_key_vault_key" "security-kv-key-activitylog" {
  name            = "Security-Team-kv-activitylog-key"
  expiration_date = "2024-11-19T11:13:13Z"
  key_opts        = ["sign", "verify", "wrapKey", "unwrapKey", "encrypt", "decrypt"]
  key_size        = 2048
  key_type        = "RSA"
  key_vault_id    = var.key-vault-id


  depends_on = [
    azurerm_key_vault_access_policy.security-kv-policy-activitylog-storage1,
    azurerm_key_vault_access_policy.security-kv-policy-activitylog-storage2,
  ]

  tags = {
    environment = "sec"
  }
}

resource "azurerm_storage_account_customer_managed_key" "security-storage1-encryption" {
  storage_account_id = azurerm_storage_account.security-storageaccount-1.id
  key_vault_id       = var.key-vault-id
  key_name           = azurerm_key_vault_key.security-kv-key-activitylog.name
}

resource "azurerm_storage_account_customer_managed_key" "security-storage2-encryption" {
  storage_account_id = azurerm_storage_account.security-storageaccount-2.id
  key_vault_id       = var.key-vault-id
  key_name           = azurerm_key_vault_key.security-kv-key-activitylog.name
}

### creating PrivateEndpoint for storage 1 and 2

# Create the network VNET
resource "azurerm_virtual_network" "security-vn-endpoint1" {
  name                = "Security-Team-network-storage1Endpoint-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "sec"
  }
}

# define a subnect for our EndPoint
resource "azurerm_subnet" "security-subnet-endpoint1" {
  name                 = "Security-Team-subnet-storage1Endpoint-${random_string.suffix.result}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.security-vn-endpoint1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_dns_zone" "security-private-dns1" {
  name                = "privatelink1.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "security-dns-networklink1" {
  name                  = "Security-Team-subnet-dns-networklink1-${random_string.suffix.result}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.security-private-dns1.name
  virtual_network_id    = azurerm_virtual_network.security-vn-endpoint1.id
}

# Create Private Endpint1
resource "azurerm_private_endpoint" "security-endpoint1" {
  name                = "Security-Team-storage1-privateendpoint-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = azurerm_subnet.security-subnet-endpoint1.id
  private_service_connection {
    name                           = "Security-Team-storage1-PV-${random_string.suffix.result}"
    private_connection_resource_id = azurerm_storage_account.security-storageaccount-1.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

# Create Private Endpint
resource "azurerm_private_endpoint" "security-endpoint2" {
  name                = "Security-Team-storage2-privateendpoint-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = azurerm_subnet.security-subnet-endpoint1.id
  private_service_connection {
    name                           = "Security-Team-storage2-PV-${random_string.suffix.result}"
    private_connection_resource_id = azurerm_storage_account.security-storageaccount-2.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}
