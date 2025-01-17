resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "security-kv" {
  name                        = "Security-KV-New-${random_string.suffix.result}"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  // it has something with the disk encryption set purge also
  purge_protection_enabled = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = {
    environment = "sec"
  }
}

resource "azurerm_key_vault_access_policy" "security-kv-policy-user" {
  key_vault_id = azurerm_key_vault.security-kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

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
    "Set",
    "Delete",
    "Purge",
    "Recover",
    "List"
  ]

  storage_permissions = [
    "Get",
    "Delete",
    "List",
    "Purge",
    "Recover"
  ]

  depends_on = [
    azurerm_key_vault.security-kv
  ]
}

resource "azurerm_key_vault_key" "security-kv-key" {
  name            = "Security-Team-kv-sql-key1"
  expiration_date = "2024-11-19T11:13:13Z"
  key_opts        = ["sign", "verify", "wrapKey", "unwrapKey", "encrypt", "decrypt"]
  key_size        = 2048
  key_type        = "RSA"
  key_vault_id    = azurerm_key_vault.security-kv.id

  depends_on = [
    azurerm_key_vault_access_policy.security-kv-policy-user
  ]

  tags = {
    environment = "sec"
  }
}

resource "azurerm_key_vault_key" "security-kv-key-linux" {
  name            = "Security-Team-kv-vm-linux"
  expiration_date = "2024-12-02T15:36:04Z"
  key_opts        = ["sign", "verify", "wrapKey", "unwrapKey", "encrypt", "decrypt"]
  key_size        = 2048
  key_type        = "RSA"
  key_vault_id    = azurerm_key_vault.security-kv.id


  depends_on = [
    azurerm_key_vault_access_policy.security-kv-policy-user
  ]

  tags = {
    environment = "sec"
  }
}

# related to Ensure that logging for Azure Key Vault is 'Enabled'

resource "azurerm_log_analytics_workspace" "security-workspace2" {
  name                = "Security-Team-workspace2"
  resource_group_name = var.resource_group_name
  location            = var.location
  #sku                 = "Free"
  retention_in_days = 30

  depends_on = [
    azurerm_key_vault.security-kv
  ]
}

resource "azurerm_monitor_diagnostic_setting" "security-kv-diagnostic" {
  name                       = "Security-Team-kv-diagnostic"
  target_resource_id         = azurerm_key_vault.security-kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.security-workspace2.id

  log {
    category = "AuditEvent"
    # Azure has updated its policies, and it seems that setting retention periods directly in diagnostic settings for certain resources is no longer supported.
    # The retention can be controlled at the Log Analytics workspace level instead of at the individual diagnostic setting level.
    enabled = true # Enable auditing

    retention_policy {
      enabled = true
      # Azure has updated its policies, and it seems that setting retention periods directly in diagnostic settings for certain resources is no longer supported.
      //days    = 180  # Set retention to 180 days
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
      //days = 0
    }
  }

  depends_on = [
    azurerm_log_analytics_workspace.security-workspace2
  ]
}

