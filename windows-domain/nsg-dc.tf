
# Active Directory NSG for Domain Controllers 


# Create the security group for AD Domain Controllers
resource "azurerm_network_security_group" "active-directory-dc-nsg" {
  name                = "${replace(lower(var.app_name), " ", "-")}-${var.environment}-dc-nsg"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name

  tags = {
    Name        = "${lower(var.app_name)}-${var.environment}-dc-sg"
    description = "NSG For AD Domain Controllers"
    Environment = var.environment
  }
}


# Inbound Rules


# Port 53 DNS TCP
resource "azurerm_network_security_rule" "tcp_53_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "53-DNS-tcp-${count.index + 1}-Inbound"
  description                 = "53-DNS-tcp-${count.index + 1}-Inbound"
  priority                    = (100 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 53 DNS UDP
resource "azurerm_network_security_rule" "udp_53_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "53-DNS-udp-${count.index + 1}-Inbound"
  description                 = "53-DNS-udp-${count.index + 1}-Inbound"
  priority                    = (110 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 88 Kerberos TCP
resource "azurerm_network_security_rule" "tcp_88_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "88-Kerb-${count.index + 1}-Inbound"
  description                 = "88-Kerb-${count.index + 1}-Inbound"
  priority                    = (120 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "88"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 88 Kerberos UDP
resource "azurerm_network_security_rule" "udp_88_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "88-Kerb-udp-${count.index + 1}-Inbound"
  description                 = "88-Kerb-udp-${count.index + 1}-Inbound"
  priority                    = (130 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "88"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 123 W32Time UDP
resource "azurerm_network_security_rule" "udp_123_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "123-${count.index + 1}-Inbound"
  description                 = "123-${count.index + 1}-Inbound"
  priority                    = (140 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "123"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 135 RPC TCP
resource "azurerm_network_security_rule" "tcp_135_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "135-RPC-${count.index + 1}-Inbound"
  description                 = "135-RPC-${count.index + 1}-Inbound"
  priority                    = (150 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "135"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 137-138 NetLogon UDP
resource "azurerm_network_security_rule" "udp_137-138_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "137-138-${count.index + 1}-Inbound"
  description                 = "137-138-${count.index + 1}-Inbound"
  priority                    = (160 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "137-138"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 139 NetLogon TCP
resource "azurerm_network_security_rule" "tcp_139_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "139-${count.index + 1}-Inbound"
  description                 = "139-${count.index + 1}-Inbound"
  priority                    = (170 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "139"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 389 LDAP TCP
resource "azurerm_network_security_rule" "tcp_389_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "389-LDAP-${count.index + 1}-Inbound"
  description                 = "389-LDAP-${count.index + 1}-Inbound"
  priority                    = (180 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "389"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 389 LDAP UDP
resource "azurerm_network_security_rule" "udp_389_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "389-udp-${count.index + 1}-Inbound"
  description                 = "389-udp-${count.index + 1}-Inbound"
  priority                    = (190 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "389"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 445 SMB TCP
resource "azurerm_network_security_rule" "tcp_445_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "445-SMB-${count.index + 1}-Inbound"
  description                 = "445-SMB-${count.index + 1}-Inbound"
  priority                    = (200 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 464 Kerberos Authentication TCP
resource "azurerm_network_security_rule" "tcp_464_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "464-Kerb-tcp-${count.index + 1}-Inbound"
  description                 = "464-Kerb-tcp-${count.index + 1}-Inbound"
  priority                    = (210 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "464"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 464 Kerberos Authentication UDP
resource "azurerm_network_security_rule" "udp_464_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "464-Kerb-udp-${count.index + 1}-Inbound"
  description                 = "464-Kerb-udp-${count.index + 1}-Inbound"
  priority                    = (220 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "464"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 636 LDAP SSL TCP
resource "azurerm_network_security_rule" "tcp_636_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "636-tcp-${count.index + 1}-Inbound"
  description                 = "636-tcp-${count.index + 1}-Inbound"
  priority                    = (230 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "636"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 3268-3269 LDAP GC TCP
resource "azurerm_network_security_rule" "tcp_3268-3269_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "3268-3269-TCP-${count.index + 1}-Inbound"
  description                 = "3268-3269-TCP-${count.index + 1}-Inbound"
  priority                    = (240 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3268-3269"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 49152-65535 TCP
resource "azurerm_network_security_rule" "tcp_49152-65535_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "49152-65535${count.index + 1}-Inbound"
  description                 = "49152-65535${count.index + 1}-Inbound"
  priority                    = (250 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "49152-65535"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 49152-65535 UDP
resource "azurerm_network_security_rule" "udp_49152-65535_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "49152-65535-UDP-DC${count.index + 1}-Inbound"
  description                 = "49152-65535-UDP-DC${count.index + 1}-Inbound"
  priority                    = (260 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "49152-65535"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}

# Allow ping AD Domain Controllers
resource "azurerm_network_security_rule" "icmp_dc_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "Ping-${count.index + 1}-Inbound"
  description                 = "Ping-${count.index + 1}-Inbound"
  priority                    = (270 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = local.dns_dc_servers[count.index]
  destination_address_prefix  = "*"
}


# Outbound Rules


# Port 53 DNS TCP
resource "azurerm_network_security_rule" "tcp_53_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "53-TCP-${count.index + 1}-Outbound"
  description                 = "53-TCP-${count.index + 1}-Outbound"
  priority                    = (100 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 53 DNS UDP
resource "azurerm_network_security_rule" "udp_53_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "53-DNS-${count.index + 1}-outbound"
  description                 = "53-DNS-${count.index + 1}-outbound"
  priority                    = (110 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 88 Kerberos TCP
resource "azurerm_network_security_rule" "tcp_88_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "88-Kerb-${count.index + 1}-outbound"
  description                 = "88-Kerb-${count.index + 1}-outbound"
  priority                    = (120 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "88"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 88 Kerberos UDP
resource "azurerm_network_security_rule" "udp_88_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "A88-Kerb-udp-${count.index + 1}-outbound"
  description                 = "88-Kerb-udp-${count.index + 1}-outbound"
  priority                    = (130 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "88"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 123 W32Time UDP
resource "azurerm_network_security_rule" "udp_123_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "123-UDP-${count.index + 1}-Outbound"
  description                 = "123-UDP-${count.index + 1}-Outbound"
  priority                    = (140 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "123"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 135 RPC TCP
resource "azurerm_network_security_rule" "tcp_135_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "135-RPC-${count.index + 1}-outbound"
  description                 = "135-RPC-${count.index + 1}-outbound"
  priority                    = (150 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "135"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 137-138 NetLogon UDP
resource "azurerm_network_security_rule" "udp_137-138_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "137-138-UDP-${count.index + 1}-Outbound"
  description                 = "137-138-UDP-${count.index + 1}-Outbound"
  priority                    = (160 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "137-138"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 139 NetLogon TCP
resource "azurerm_network_security_rule" "tcp_139_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "139-TCP-${count.index + 1}-Outbound"
  description                 = "139-TCP-${count.index + 1}-Outbound"
  priority                    = (170 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "139"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 389 LDAP TCP
resource "azurerm_network_security_rule" "tcp_389_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
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
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 389 LDAP UDP
resource "azurerm_network_security_rule" "udp_389_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "389-UDP-${count.index + 1}-Outbound"
  description                 = "389-UDP-${count.index + 1}-Outbound"
  priority                    = (190 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "389"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 445 SMB TCP
resource "azurerm_network_security_rule" "tcp_445_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "445-SMB-${count.index + 1}-outbound"
  description                 = "445-SMB-${count.index + 1}-outbound"
  priority                    = (200 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 464 Kerberos Authentication TCP
resource "azurerm_network_security_rule" "tcp_464_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "464-TCP-${count.index + 1}-Outbound"
  description                 = "464-TCP-${count.index + 1}-Outbound"
  priority                    = (210 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "464"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 464 Kerberos Authentication UDP
resource "azurerm_network_security_rule" "udp_464_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "464-UDP-${count.index + 1}-Outbound"
  description                 = "464-UDP-${count.index + 1}-Outbound"
  priority                    = (220 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "464"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

# Port 636 LDAP SSL TCP
resource "azurerm_network_security_rule" "tcp_636_dc_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_dc_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-dc-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "636-TCP-${count.index + 1}-Outbound"
  description                 = "636-TCP-${count.index + 1}-Outbound"
  priority                    = (230 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "636"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_dc_servers[count.index]
}

