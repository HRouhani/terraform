terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.38.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}


# Create a resource group
resource "azurerm_resource_group" "security-rg" {
  name     = "Security-Team-resources-${random_string.suffix.result}"
  location = "Germany West Central"
  tags = {
    environment = "sec"

  }
}

# to make this test fales -> Ensure That No Custom Subscription Owner Roles Are Created  -> make action ["*"] otherwise will skipp
data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "security-customeRole" { # Sensitive
  name  = "Security-Team-customerole1-${random_string.suffix.result}"
  scope = data.azurerm_subscription.primary.id

  permissions {
    //actions     = ["*"]
    actions     = ["Microsoft.Compute/*"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id
  ]
}

# call the Module to create Linux VM
module "VM" {
  source                  = "./VM"
  Linux_VM_name           = "Security-Team-vm-linux-1-${random_string.suffix.result}"
  resource_group_name     = azurerm_resource_group.security-rg.name
  location                = azurerm_resource_group.security-rg.location
  size                    = "Standard_E2bds_v5"
  disk-encryption-set1-id = module.StorageDisk.disk-encryption-set1
  depends_on = [
    module.StorageDisk,
    module.KeyVault
  ]
}

# call the Module to create Storage & Disks
module "StorageDisk" {
  source              = "./StorageDisk"
  resource_group_name = azurerm_resource_group.security-rg.name
  location            = azurerm_resource_group.security-rg.location
  location2           = "eastus"
  linux-key-id        = module.KeyVault.linux-key-id
  key-vault-id        = module.KeyVault.key-vault-id
  subscription        = var.subscription
  depends_on = [
    module.KeyVault
  ]
}

module "KeyVault" {
  source              = "./KeyVault"
  resource_group_name = azurerm_resource_group.security-rg.name
  location            = azurerm_resource_group.security-rg.location
}

module "DataBases" {
  source                       = "./DataBases"
  resource_group_name          = azurerm_resource_group.security-rg.name
  location                     = azurerm_resource_group.security-rg.location
  storage-endpoint             = module.StorageDisk.storage-endpoint
  storage-access-key           = module.StorageDisk.storage-access-key
  storage-account-name2        = module.StorageDisk.storage-account-name2
  subscription                 = var.subscription
  key-vault-id                 = module.KeyVault.key-vault-id
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  login_username_mssql         = var.login_username_mssql
  object_id_mssql              = var.object_id_mssql
  emails                       = var.emails
  depends_on = [
    module.StorageDisk,
    module.KeyVault
  ]
}

module "AppMonitor" {
  source              = "./AppMonitor"
  resource_group_name = azurerm_resource_group.security-rg.name
  location            = azurerm_resource_group.security-rg.location
  resource_group_id   = azurerm_resource_group.security-rg.id
  scope_publicIP      = module.VM.public-ip
  scope_sqlserver     = module.DataBases.sql-server
  subscription        = var.subscription
  location-westEU     = "westeurope"
  email_address       = var.emails
  depends_on = [
    module.KeyVault
  ]
}
