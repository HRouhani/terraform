/* resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
} */

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "insights" {
  name                = "security-team-logs-${random_string.suffix.result}"
  location            = azurerm_resource_group.security-rg-aks.location
  resource_group_name = azurerm_resource_group.security-rg-aks.name
  retention_in_days   = 30
}