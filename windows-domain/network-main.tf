
# Network - Main
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Create a resource group for network
resource "azurerm_resource_group" "network-rg" {
  name     = "${lower(replace(var.app_name, " ", "-"))}-${random_string.suffix.result}"
  location = var.location
  tags = {
    application = var.app_name
    environment = var.environment
  }
}

# Create the network VNET
resource "azurerm_virtual_network" "network-vnet" {
  name                = "${lower(replace(var.app_name, " ", "-"))}-${random_string.suffix.result}"
  address_space       = [var.network-vnet-cidr]
  resource_group_name = azurerm_resource_group.network-rg.name
  location            = azurerm_resource_group.network-rg.location
  tags = {
    application = var.app_name
    environment = var.environment
  }
}

# Create a subnet for Network
resource "azurerm_subnet" "network-subnet" {
  name                 = "${lower(replace(var.app_name, " ", "-"))}-${random_string.suffix.result}"
  address_prefixes     = [var.network-subnet-cidr]
  virtual_network_name = azurerm_virtual_network.network-vnet.name
  resource_group_name  = azurerm_resource_group.network-rg.name
}

