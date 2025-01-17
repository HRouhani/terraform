
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_mssql_server" "security-sql-server-1" {
  name                         = "security-team-sql-server1-${random_string.suffix.result}"
  resource_group_name          = var.resource_group_name
  location                     = "eastus"
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  tags = {
    environment = "sec"
  }
  version = "12.0"
  azuread_administrator {
    login_username = var.login_username_mssql
    object_id      = var.object_id_mssql
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_database" "security-sql-db" {
  name                 = "Security-Team-SQL-1"
  server_id            = azurerm_mssql_server.security-sql-server-1.id
  storage_account_type = "Local"

  tags = {
    environment = "sec"
  }

}

# related to Ensure Default Network Access Rule for Storage Accounts is Set to Deny 
# the 3th storage has been created in order for mssql be able to create a blob storage for extended auditing policy before we close the access to by netw rules

# creating Storage Account
resource "azurerm_storage_account" "security-storageaccount-3" {
  name                     = "securityteam3${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
  # related to secure transfer enabled
  enable_https_traffic_only = true
  queue_encryption_key_type = "Account"
  table_encryption_key_type = "Account"
  # both related to Ensure that 'Public access level' is disabled for storage accounts with blob containers
  # public_network_access_enabled   = false
  # allow_nested_items_to_be_public = false
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

  depends_on = [
    azurerm_mysql_server.security-mysql-server1
  ]
  infrastructure_encryption_enabled = true
}

resource "azurerm_mssql_server_extended_auditing_policy" "security-sql-server-audit" {
  enabled                                 = true
  log_monitoring_enabled                  = true
  server_id                               = azurerm_mssql_server.security-sql-server-1.id
  storage_account_subscription_id         = var.subscription
  storage_endpoint                        = azurerm_storage_account.security-storageaccount-3.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.security-storageaccount-3.primary_access_key
  storage_account_access_key_is_secondary = false

  depends_on = [
    azurerm_storage_account.security-storageaccount-3
  ]
}

# and assigned the IP address of the person who runs the terraform to the ource_address_prefix
data "http" "clientip" {
  url = "https://ipv4.icanhazip.com/"
}

resource "azurerm_storage_account_network_rules" "security-storage3-networkrule" {
  storage_account_id = azurerm_storage_account.security-storageaccount-3.id
  default_action     = "Deny"
  bypass             = ["Logging", "Metrics", "AzureServices"]
  ip_rules           = ["${chomp(data.http.clientip.response_body)}"]
  # NOTE The order here matters: We cannot create storage

  depends_on = [
    azurerm_mssql_server_extended_auditing_policy.security-sql-server-audit
  ]
}

resource "azurerm_mssql_server_microsoft_support_auditing_policy" "security-sql-server-support-audit" {
  enabled                = true
  log_monitoring_enabled = true
  server_id              = azurerm_mssql_server.security-sql-server-1.id

  depends_on = [
    azurerm_mssql_server.security-sql-server-1
  ]
}

# related to Ensure SQL server's Transparent Data Encryption (TDE) protector is encrypted with Customer-managed key (next 3 blocks)

resource "azurerm_key_vault_access_policy" "security-kv-policy-mssql" {

  key_vault_id = var.key-vault-id
  tenant_id    = azurerm_mssql_server.security-sql-server-1.identity[0].tenant_id
  object_id    = azurerm_mssql_server.security-sql-server-1.identity[0].principal_id

  key_permissions = [
    "Get",
    "Decrypt",
    "Encrypt",
    "Sign",
    "UnwrapKey",
    "Verify",
    "WrapKey",
    "Update"
  ]

  depends_on = [
    azurerm_mssql_server.security-sql-server-1
  ]
}

resource "azurerm_key_vault_key" "security-kv-key-mssql" {
  name            = "Security-Team-kv-mssql"
  expiration_date = "2024-12-02T15:36:04Z"
  key_opts        = ["sign", "verify", "wrapKey", "unwrapKey", "encrypt", "decrypt"]
  key_size        = 2048
  key_type        = "RSA"
  key_vault_id    = var.key-vault-id

  depends_on = [
    azurerm_key_vault_access_policy.security-kv-policy-mssql
  ]
}

resource "azurerm_mssql_server_transparent_data_encryption" "security-sql-server-tda" {
  server_id        = azurerm_mssql_server.security-sql-server-1.id
  key_vault_key_id = azurerm_key_vault_key.security-kv-key-mssql.id

  depends_on = [
    azurerm_key_vault_key.security-kv-key-mssql
  ]
}


resource "azurerm_mssql_firewall_rule" "security-sql-fw-rule-1" {
  end_ip_address   = chomp(data.http.clientip.response_body)
  name             = "ClientIPAddress1"
  server_id        = azurerm_mssql_server.security-sql-server-1.id
  start_ip_address = chomp(data.http.clientip.response_body)

  depends_on = [
    azurerm_mssql_server.security-sql-server-1
  ]
}

resource "azurerm_mssql_firewall_rule" "security-sql-fw-rule-2" {
  end_ip_address   = chomp(data.http.clientip.response_body)
  name             = "ClientIPAddress2"
  server_id        = azurerm_mssql_server.security-sql-server-1.id
  start_ip_address = chomp(data.http.clientip.response_body)

  depends_on = [
    azurerm_mssql_server.security-sql-server-1
  ]
}

resource "azurerm_mssql_server_security_alert_policy" "security-sql-server-sap" {
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mssql_server.security-sql-server-1.name
  state               = "Enabled"

  depends_on = [
    azurerm_mssql_server.security-sql-server-1
  ]
}

resource "azurerm_mssql_server_vulnerability_assessment" "security-sql-server-va" {
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.security-sql-server-sap.id
  storage_container_path          = "https://${var.storage-account-name2}.blob.core.windows.net/vulnerability-assessment/"

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails                    = [var.emails, ]
  }

  depends_on = [
    azurerm_mssql_server_security_alert_policy.security-sql-server-sap
  ]
}

resource "azurerm_storage_container" "security-sc-1" {
  name                  = "sqldbauditlogs"
  storage_account_name  = var.storage-account-name2
  container_access_type = "private"
}

resource "azurerm_storage_container" "security-sc-2" {
  name                  = "vulnerability-assessment"
  storage_account_name  = var.storage-account-name2
  container_access_type = "private"
}

resource "azurerm_postgresql_server" "security-postgresql-server-1" {
  name                  = "securityteam-postgresql1-${random_string.suffix.result}"
  resource_group_name   = var.resource_group_name
  location              = "westeurope"
  sku_name              = "B_Gen5_2"
  version               = "11"
  backup_retention_days = 7
  #public_network_access_enabled    = false  
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  # added new for making pass, it is not working!
  //infrastructure_encryption_enabled = true
  # related tp 'Allow access to Azure services' for PostgreSQL Database Server is disabled 
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password

  //infrastructure_encryption_enabled = true  # This is where you'd set the double encryption But not available yet through Terraform

  tags = {
    environment = "sec"
  }
}

# related to server parameter 'log_disconnections' is set to 'ON' for PostgreSQL 
resource "azurerm_postgresql_configuration" "security-postgresql-config1" {
  name                = "log_disconnections"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.security-postgresql-server-1.name
  value               = "on"

  depends_on = [
    azurerm_postgresql_server.security-postgresql-server-1
  ]
}

# Ensure Server Parameter 'log_retention_days' is greater than 3 days for PostgreSQL Database Server
resource "azurerm_postgresql_configuration" "security-postgresql-config2" {
  name                = "log_retention_days"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.security-postgresql-server-1.name
  value               = "7"

  depends_on = [
    azurerm_postgresql_server.security-postgresql-server-1
  ]
}

# related to Ensure Server Parameter 'log_checkpoints' is set to 'ON' for PostgreSQL Database Server
resource "azurerm_postgresql_configuration" "security-postgresql-config3" {
  name                = "log_checkpoints"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.security-postgresql-server-1.name
  value               = "on"

  depends_on = [
    azurerm_postgresql_server.security-postgresql-server-1
  ]
}

#related to Ensure server parameter 'connection_throttling' is set to 'ON' for PostgreSQL Database Server
resource "azurerm_postgresql_configuration" "security-postgresql-config4" {
  name                = "connection_throttling"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.security-postgresql-server-1.name
  value               = "on"

  depends_on = [
    azurerm_postgresql_server.security-postgresql-server-1
  ]
}

resource "azurerm_mysql_server" "security-mysql-server1" {
  location                     = "eastus"
  name                         = "securityteam-mysql1-${random_string.suffix.result}"
  resource_group_name          = var.resource_group_name
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password

  sku_name = "B_Gen5_2"
  version  = "8.0"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"


  tags = {
    Environment = "sec"
  }
}

# cosmosdb 
resource "azurerm_cosmosdb_account" "security-cosmosdb-server1" {
  name                = "securityteam-cosmos-mongo-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = "Germany West Central"
  offer_type          = "Standard"
  kind                = "MongoDB"
  enable_free_tier    = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    failover_priority = 0
    location          = "eastus"
  }

  tags = {
    environment = "sec"
  }
  is_virtual_network_filter_enabled = "true"
}

# Eventhub
resource "azurerm_eventhub_namespace" "securityeventhub" {
  location            = "eastus"
  name                = "Securityteam-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  capacity            = 1
  #zone_redundant      = true

  depends_on = [
    var.resource_group_name
  ]
}

resource "azurerm_eventhub" "security-eventhub-activitylogs" {
  message_retention   = 7
  name                = "insights-activity-logs"
  namespace_name      = azurerm_eventhub_namespace.securityeventhub.name
  partition_count     = 4
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_eventhub_namespace.securityeventhub
  ]
}

resource "azurerm_eventhub_namespace_authorization_rule" "security-eventhub-authrule" {
  listen              = true
  manage              = true
  name                = "RootManageSharedAccessKey-${random_string.suffix.result}"
  namespace_name      = azurerm_eventhub_namespace.securityeventhub.name
  resource_group_name = var.resource_group_name
  send                = true

  depends_on = [
    azurerm_eventhub_namespace.securityeventhub
  ]
}

resource "azurerm_eventhub_consumer_group" "security-eventhub-consumergroup" {
  eventhub_name       = "insights-activity-logs"
  name                = "Default"
  namespace_name      = azurerm_eventhub_namespace.securityeventhub.name
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_eventhub.security-eventhub-activitylogs
  ]
}

# related to encrypting the StorageAccount3
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "security-kv-policy-activitylog-storage3" {
  key_vault_id = var.key-vault-id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_storage_account.security-storageaccount-3.identity.0.principal_id

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
    azurerm_storage_account.security-storageaccount-3
  ]
}

resource "azurerm_key_vault_key" "security-kv-key-activitylog2" {
  name            = "Security-Team-kv-activitylog-key2"
  expiration_date = "2024-11-19T11:13:13Z"
  key_opts        = ["sign", "verify", "wrapKey", "unwrapKey", "encrypt", "decrypt"]
  key_size        = 2048
  key_type        = "RSA"
  key_vault_id    = var.key-vault-id


  depends_on = [
    azurerm_key_vault_access_policy.security-kv-policy-activitylog-storage3
  ]

  tags = {
    environment = "sec"
  }
}

resource "azurerm_storage_account_customer_managed_key" "security-storage3-encryption" {
  storage_account_id = azurerm_storage_account.security-storageaccount-3.id
  key_vault_id       = var.key-vault-id
  key_name           = azurerm_key_vault_key.security-kv-key-activitylog2.name
}

### creating PrivateEndpoint for storages3

# Create the network VNET
resource "azurerm_virtual_network" "security-vn-endpoint2" {
  name                = "Security-Team-network-storage3Endpoint-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "sec"
  }
}

# define a subnect for our EndPoint
resource "azurerm_subnet" "security-subnet-endpoint2" {
  name                                      = "Security-Team-subnet-storage3Endpoint-${random_string.suffix.result}"
  resource_group_name                       = var.resource_group_name
  virtual_network_name                      = azurerm_virtual_network.security-vn-endpoint2.name
  address_prefixes                          = ["10.0.1.0/24"]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_private_dns_zone" "security-private-dns2" {
  name                = "privatelink2.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "security-dns-networklink1" {
  name                  = "Security-Team-subnet-dns-networklink2-${random_string.suffix.result}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.security-private-dns2.name
  virtual_network_id    = azurerm_virtual_network.security-vn-endpoint2.id
}

# Create Private Endpint1
resource "azurerm_private_endpoint" "security-endpoint2" {
  name                = "Security-Team-storage3-privateendpoint-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = azurerm_subnet.security-subnet-endpoint2.id
  private_service_connection {
    name                           = "Security-Team-storage2-PV-${random_string.suffix.result}"
    private_connection_resource_id = azurerm_storage_account.security-storageaccount-3.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

