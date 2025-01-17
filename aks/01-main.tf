resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# and assigned the IP address of the person who runs the terraform to the ource_address_prefix
data "http" "clientip" {
  url = "https://ipv4.icanhazip.com/"
}

locals {
  userIP = "${chomp(data.http.clientip.response_body)}/32"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${azurerm_resource_group.security-rg-aks.name}-cluster"
  location            = azurerm_resource_group.security-rg-aks.location
  resource_group_name = azurerm_resource_group.security-rg-aks.name
  dns_prefix          = "${azurerm_resource_group.security-rg-aks.name}-cluster"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${azurerm_resource_group.security-rg-aks.name}-nrg"

  private_cluster_enabled = true

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
  }

  #api_server_access_profile {
  #  authorized_ip_ranges = ["40.74.28.0/23"]
  #}

  #azure_policy_enabled = true

  default_node_pool {
    name                 = "securitypool"
    vm_size              = "Standard_D2_v2"
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    #availability_zones   = [1, 2, 3]
    #zones = [1, 2, 3]
    enable_auto_scaling   = true
    enable_node_public_ip = true
    node_count            = var.node_count
    max_count             = 3
    min_count             = 1
    os_disk_size_gb       = 30
    type                  = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = "dev"
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
    tags = {
      "nodepool-type" = "system"
      "environment"   = "dev"
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
  }

  # Identity (System Assigned or Service Principal)
  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
  }
  # Add On Profiles
  #  addon_profile {
  #    azure_policy {enabled =  true}
  #    oms_agent {
  #      enabled =  true
  #      log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
  #    }
  #  }

  # RBAC and Azure AD Integration Block
  #  role_based_access_control {
  #    enabled = true
  #    azure_active_directory {
  #      managed = true
  #      admin_group_object_ids = [azuread_group.aks_administrators.id]
  #    }
  #  }
  # Added June 2023
  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = [azuread_group.aks_administrators.id]
  }

  # Windows Profile (for future development)
  windows_profile {
    admin_username = var.windows_admin_username
    admin_password = var.windows_admin_password
  }

  # Linux Profile
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      #key_data = file(var.ssh_public_key)
      key_data = tls_private_key.vm_ssh.public_key_openssh
    }
  }

  #  # Network Profile
  #  network_profile {
  #    network_plugin    = "azure"
  #    load_balancer_sku = "standard"
  #  }

  tags = {
    Environment = "sec"
  }

  depends_on = [tls_private_key.vm_ssh]
}
