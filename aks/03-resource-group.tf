
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}


# Create a resource group
resource "azurerm_resource_group" "security-rg-aks" {
  name = "${var.resource_group_name}-${random_string.suffix.result}"
  #location = "Germany West Central"
  location = var.location

  tags = {
    environment = "sec"

  }
}


resource "azurerm_container_registry" "acr" {
  name                = "containerRegistrypass${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.security-rg-aks.name
  location            = azurerm_resource_group.security-rg-aks.location
  sku                 = "Standard"
  admin_enabled       = false
  #georeplications {
  #  location                = "East US"
  #  zone_redundancy_enabled = true
  #  tags                    = {}
  #}
  #georeplications {
  #  location                = "North Europe"
  #  zone_redundancy_enabled = true
  #  tags                    = {}
  #}
}