data "azurerm_resources" "cluster" {
  #resource_group_name = azurerm_kubernetes_cluster.cluster.node_resource_group
  #resource_group_name = azurerm_resource_group.security-rg-aks.name
  resource_group_name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group

  type = "Microsoft.Network/networkSecurityGroups"
  #depends_on = [azurerm_kubernetes_cluster.cluster]
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}

resource "azurerm_network_security_rule" "nsg-cluster" {
  name                       = "aks-ssh-inbound"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  #resource_group_name         = azurerm_kubernetes_cluster.cluster.node_resource_group
  #resource_group_name         = azurerm_resource_group.security-rg-aks.name
  resource_group_name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  #network_security_group_name = data.azurerm_resources.cluster.resources.0.name
  network_security_group_name = data.azurerm_resources.cluster.resources.0.name

  depends_on = [data.azurerm_resources.cluster]
}