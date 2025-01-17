# Active Directory NSG for Clients


# Create the security group for AD Users
resource "azurerm_network_security_group" "active-directory-client-nsg" {
  name                = "${replace(lower(var.app_name), " ", "-")}-${var.environment}-client-nsg"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name

  tags = {
    Name        = "${lower(var.app_name)}-${var.environment}-client-sg"
    description = "NSG for AD Clients"
    Environment = var.environment
  }
}


# Inbound Rules

# Port 53 DNS UDP
resource "azurerm_network_security_rule" "udp_53_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "53-DNS-udp-${count.index + 1}-Inbound"
  description                 = "53-DNS-udp-${count.index + 1}-Inbound"
  priority                    = (150 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = local.dns_dj_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 88 Kerberos TCP
resource "azurerm_network_security_rule" "tcp_88_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "88-Kerb-${count.index + 1}-Inbound"
  description                 = "88-Kerb-${count.index + 1}-Inbound"
  priority                    = (160 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "88"
  source_address_prefix       = local.dns_dj_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 135 RPC TCP
resource "azurerm_network_security_rule" "tcp_135_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "135-RPC-${count.index + 1}-Inbound"
  description                 = "135-RPC-${count.index + 1}-Inbound"
  priority                    = (170 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "135"
  source_address_prefix       = local.dns_dj_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 389 LDAP TCP
resource "azurerm_network_security_rule" "tcp_389_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "389-LDAP-${count.index + 1}-Inbound"
  description                 = "389-LDAP-${count.index + 1}-Inbound"
  priority                    = (180 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "389"
  source_address_prefix       = local.dns_dj_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 445 SMB TCP
resource "azurerm_network_security_rule" "tcp_445_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "445-SMB-${count.index + 1}-Inbound"
  description                 = "445-SMB-${count.index + 1}-Inbound"
  priority                    = (190 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = local.dns_dj_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 49152-65535 TCP
resource "azurerm_network_security_rule" "tcp_49152-65535_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "49152-65535${count.index + 1}-Inbound"
  description                 = "49152-65535${count.index + 1}-Inbound"
  priority                    = (200 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "49152-65535"
  source_address_prefix       = local.dns_dj_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 49152-65535 UDP
resource "azurerm_network_security_rule" "udp_49152-65535_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "49152-65535-UDP-DC${count.index + 1}-Inbound"
  description                 = "49152-65535-UDP-DC${count.index + 1}-Inbound"
  priority                    = (210 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "49152-65535"
  source_address_prefix       = local.dns_dj_servers[count.index]
  destination_address_prefix  = "*"
}

# Allow ping AD Domain Controllers
resource "azurerm_network_security_rule" "icmp_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "Ping-${count.index + 1}-Inbound"
  description                 = "Ping-${count.index + 1}-Inbound"
  priority                    = (220 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = local.dns_dj_servers[count.index]
  destination_address_prefix  = "*"
}


# Outbound Rules


# Port 53 DNS UDP
resource "azurerm_network_security_rule" "udp_53_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "53-DNS-${count.index + 1}-outbound"
  description                 = "53-DNS-${count.index + 1}-outbound"
  priority                    = (150 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dj_servers[count.index]
}

# Port 88 Kerberos TCP
resource "azurerm_network_security_rule" "tcp_88_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "88-Kerb-${count.index + 1}-outbound"
  description                 = "88-Kerb-${count.index + 1}-outbound"
  priority                    = (160 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "88"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dj_servers[count.index]
}

# Port 135 RPC TCP
resource "azurerm_network_security_rule" "tcp_135_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "135-RPC-${count.index + 1}-outbound"
  description                 = "135-RPC-${count.index + 1}-outbound"
  priority                    = (170 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "135"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dj_servers[count.index]
}

# Port 389 LDAP TCP
resource "azurerm_network_security_rule" "tcp_389_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "389-LDAP-${count.index + 1}-outbound"
  description                 = "389-LDAP-${count.index + 1}-outbound"
  priority                    = (180 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "389"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dj_servers[count.index]
}

# Port 445 SMB TCP
resource "azurerm_network_security_rule" "tcp_445_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "445-SMB-${count.index + 1}-outbound"
  description                 = "445-SMB-${count.index + 1}-outbound"
  priority                    = (190 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dj_servers[count.index]
}

# Port 49152-65535 TCP
resource "azurerm_network_security_rule" "tcp_49152-65535_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "49152-65535${count.index + 1}-outbound"
  description                 = "49152-65535${count.index + 1}-outbound"
  priority                    = (200 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "49152-65535"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dj_servers[count.index]
}

# Port 49152-65535 UDP
resource "azurerm_network_security_rule" "udp_49152-65535_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "49152-65535-UDP-DC${count.index + 1}-outbound"
  description                 = "49152-65535-UDP-DC${count.index + 1}-outbound"
  priority                    = (210 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "49152-65535"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dj_servers[count.index]
}

# Allow ping AD Domain Controllers
resource "azurerm_network_security_rule" "icmp_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dj_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "Ping-${count.index + 1}-outbound"
  description                 = "Ping-${count.index + 1}-outbound"
  priority                    = (220 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dj_servers[count.index]
}
