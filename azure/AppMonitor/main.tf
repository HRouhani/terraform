resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# related to the web app
resource "azurerm_service_plan" "security-service-plan" {
  location            = var.location-westEU
  name                = "ASP-SecurityTeamresources-${random_string.suffix.result}"
  os_type             = "Linux"
  resource_group_name = var.resource_group_name
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "security-linux-webapp" {
  location            = var.location-westEU
  name                = "security-team-webapp-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.security-service-plan.id
  # related to Ensure the web app has 'Client Certificates (Incoming client certificates)' set to 'On'
  client_certificate_enabled = true
  https_only                 = true
  # related to  Ensure that Register with Azure Active Directory is enabled on App Service
  #  Azure will generate a Service Principal for us
  identity {
    type = "SystemAssigned"
  }

  site_config {
    ftps_state = "FtpsOnly"
    # title: Ensure that 'HTTP Version' is the Latest, if Used to Run the Web App
    http2_enabled = true
  }

  auth_settings {
    enabled          = true
    default_provider = "AzureActiveDirectory"

  }

  depends_on = [
    azurerm_service_plan.security-service-plan
  ]
}

# monitor related part -> Alert rules and their corresponding actions
# created the action group which send email and the type is Webhook (other options can be EventHub, Logic App, ...)

resource "azurerm_monitor_action_group" "security-actiongroup1" {
  name                = "Security-PolicyAssign1"
  resource_group_name = var.resource_group_name
  short_name          = "Sec-PolAs1"
  email_receiver {
    email_address = var.email_address
    name          = "security-emailAction"
  }
  webhook_receiver {
    name                    = "hrouhanPol"
    service_uri             = "http://hrouhan.com"
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_action_group" "security-actiongroup2" {
  name                = "Security-PolicyAssign2"
  resource_group_name = var.resource_group_name
  short_name          = "Sec-PolAs2"
  email_receiver {
    email_address = var.email_address
    name          = "security-emailAction"
  }
  webhook_receiver {
    name                    = "hrouhanPol"
    service_uri             = "http://hrouhan.com"
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_activity_log_alert" "security-logalert1" {
  name                = "Security-policy-delete"
  resource_group_name = var.resource_group_name
  scopes              = [var.resource_group_id]
  location            = var.location-westEU
  action {
    action_group_id = azurerm_monitor_action_group.security-actiongroup1.id
  }
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Authorization/policyAssignments/delete"
    resource_type  = "microsoft.authorization/policyassignments"
  }
}

resource "azurerm_monitor_activity_log_alert" "security-logalert2" {
  name                = "Security-policy-net"
  resource_group_name = var.resource_group_name
  scopes              = [var.resource_group_id]
  location            = var.location-westEU
  action {
    action_group_id = azurerm_monitor_action_group.security-actiongroup1.id

  }
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/networkSecurityGroups/write"
    resource_type  = "microsoft.network/networksecuritygroups"
  }
}

resource "azurerm_monitor_activity_log_alert" "security-logalert3" {
  name                = "Security-policy-netDelete"
  resource_group_name = var.resource_group_name
  scopes              = [var.resource_group_id]
  location            = var.location-westEU
  action {
    action_group_id = azurerm_monitor_action_group.security-actiongroup1.id

  }
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/networkSecurityGroups/delete"
    resource_type  = "microsoft.network/networksecuritygroups"
  }
}

resource "azurerm_monitor_activity_log_alert" "security-logalert4" {
  name                = "Security-policy-public-delete"
  resource_group_name = var.resource_group_name
  scopes              = [var.resource_group_id]
  location            = var.location-westEU
  action {
    action_group_id = azurerm_monitor_action_group.security-actiongroup1.id

  }
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/publicIPAddresses/delete"
    resource_type  = "microsoft.network/publicipaddresses"
  }
}

resource "azurerm_monitor_activity_log_alert" "security-logalert5" {
  name                = "Security-policy-publicIP"
  resource_group_name = var.resource_group_name
  scopes              = [var.scope_publicIP]
  location            = var.location-westEU
  action {
    action_group_id = azurerm_monitor_action_group.security-actiongroup1.id

  }
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/publicIPAddresses/write"
  }
}

resource "azurerm_monitor_activity_log_alert" "security-logalert6" {
  name                = "Security-policy-sec"
  resource_group_name = var.resource_group_name
  scopes              = [var.resource_group_id]
  location            = var.location-westEU
  action {
    action_group_id = azurerm_monitor_action_group.security-actiongroup1.id

  }
  criteria {
    category       = "Security"
    operation_name = "Microsoft.Security/securitySolutions/write"
    resource_type  = "microsoft.security/securitysolutions"
  }
}

resource "azurerm_monitor_activity_log_alert" "security-logalert7" {
  name                = "Security-policy-secdelete"
  resource_group_name = var.resource_group_name
  scopes              = [var.resource_group_id]
  location            = var.location-westEU
  action {
    action_group_id = azurerm_monitor_action_group.security-actiongroup1.id

  }
  criteria {
    category       = "Security"
    operation_name = "Microsoft.Security/securitySolutions/delete"
    resource_type  = "microsoft.security/securitysolutions"
  }
}

resource "azurerm_monitor_activity_log_alert" "security-logalert8" {
  name                = "Security-policy-sqlCreate"
  resource_group_name = var.resource_group_name
  scopes              = [var.scope_sqlserver]
  location            = var.location-westEU
  action {
    action_group_id = azurerm_monitor_action_group.security-actiongroup1.id

  }
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Sql/servers/write"
  }
}

resource "azurerm_monitor_activity_log_alert" "security-logalert9" {
  name                = "Security-policy-sqlfirewall1"
  resource_group_name = var.resource_group_name
  scopes              = [var.resource_group_id]
  location            = var.location-westEU
  action {
    action_group_id = azurerm_monitor_action_group.security-actiongroup1.id

  }
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Sql/servers/firewallRules/write"
    resource_type  = "microsoft.sql/servers/firewallrules"
  }
}

resource "azurerm_monitor_activity_log_alert" "security-logalert10" {
  name                = "Security-policy-sqlfirewalldelete"
  resource_group_name = var.resource_group_name
  scopes              = [var.resource_group_id]
  location            = var.location-westEU
  action {
    action_group_id = azurerm_monitor_action_group.security-actiongroup1.id

  }
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Sql/servers/firewallRules/delete"
    resource_type  = "microsoft.sql/servers/firewallrules"
  }
}

resource "azurerm_monitor_activity_log_alert" "security-logalert11" {
  name                = "Security-test2"
  resource_group_name = var.resource_group_name
  scopes              = ["/subscriptions/${var.subscription}"]
  location            = var.location-westEU
  action {
    action_group_id = azurerm_monitor_action_group.security-actiongroup2.id
  }
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Insights/ActivityLogAlerts/Delete"
    resource_type  = "microsoft.insights/activitylogalerts"
  }
}

resource "azurerm_monitor_activity_log_alert" "security-logalert12" {
  name                = "Security-policy-write"
  resource_group_name = var.resource_group_name
  scopes              = [var.resource_group_id]
  location            = var.location-westEU
  action {
    action_group_id = azurerm_monitor_action_group.security-actiongroup1.id
  }
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Authorization/policyAssignments/write"
    resource_type  = "microsoft.authorization/policyassignments"
  }
}

# related to creating the diagnostic settings for activity logs in Monitor

resource "azurerm_log_analytics_workspace" "security-workspace4" {
  name                = "Security-Team-workspace4-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  #sku                 = "Free"
  retention_in_days = 30
}

resource "azurerm_monitor_diagnostic_setting" "security-storage3-diagnostic" {
  name = "Security-Team-activitylog-diagnostic-${random_string.suffix.result}"
  //target_resource_id = "/subscriptions/f1......................"
  target_resource_id         = "/subscriptions/${var.subscription}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.security-workspace4.id

  log {
    category = "Administrative"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "Security"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "Alert"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "Policy"

    retention_policy {
      enabled = false
    }
  }

  depends_on = [
    azurerm_log_analytics_workspace.security-workspace4
  ]
}

## related to creating application insight in the Workspace Mode

resource "azurerm_log_analytics_workspace" "security-workspace5" {
  name                = "Security-Team-workspace5-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "example" {
  name                = "Security-Team-appInsight-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  #workspace_id        = azurerm_log_analytics_workspace.example.id
  workspace_id     = azurerm_log_analytics_workspace.security-workspace5.id
  application_type = "web"
}

### related to the Bastion Host

resource "azurerm_virtual_network" "security-vn2" {
  name                = "Security-Team-network2-${random_string.suffix.result}"
  address_space       = ["192.168.1.0/24"]
  resource_group_name = var.resource_group_name
  #location              = var.location
  location = "westus"
}

resource "azurerm_subnet" "security-subnect2" {
  #name                 = "Security-Team-subnet2-${random_string.suffix.result}"
  name                = "AzureBastionSubnet"
  resource_group_name = var.resource_group_name
  #virtual_network_name = azurerm_virtual_network.example.name
  virtual_network_name = azurerm_virtual_network.security-vn2.name
  address_prefixes     = ["192.168.1.224/27"]
}

resource "azurerm_public_ip" "security-ip2" {
  name                = "Security-Team-ip-2-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  #location              = var.location
  location          = "westus"
  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_bastion_host" "security-bastion1" {
  name                = "Security-Team-BastionHost1-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  #location              = var.location
  location = "westus"

  ip_configuration {
    name = "Security-Team-ip-config1-${random_string.suffix.result}"
    #subnet_id            = azurerm_subnet.example.id
    subnet_id = azurerm_subnet.security-subnect2.id
    #public_ip_address_id = azurerm_public_ip.example.id
    public_ip_address_id = azurerm_public_ip.security-ip2.id
  }
}
