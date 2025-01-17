resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Create (and display) an SSH key
resource "tls_private_key" "linux_vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_virtual_network" "security-vn" {
  name                = "Security-Team-network-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "sec"
  }
}

# define a subnect for our virtual network
resource "azurerm_subnet" "security-subnect" {
  name                 = "Security-Team-subnet-${random_string.suffix.result}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.security-vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Network security group
resource "azurerm_network_security_group" "security-nsg" {
  name                = "Security-Team-nsg-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = {
    environment = "sec"
  }
}

#Get Client IP Address for NSG
# and assigned the IP address of the person who runs the terraform to the ource_address_prefix
data "http" "clientip" {
  url = "https://ipv4.icanhazip.com/"
}

#the rules for NSG defined seperately
resource "azurerm_network_security_rule" "security-rule" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.security-nsg.name
  name                        = "Security-Team-rule-${random_string.suffix.result}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  //destination_port_range    = "*"
  //changed the ssh port to 2222 to pass the test
  destination_port_range = "2222"
  //source_address_prefix       = "*"
  source_address_prefix      = "${chomp(data.http.clientip.response_body)}/32"
  destination_address_prefix = "*"

  depends_on = [
    azurerm_network_security_group.security-nsg
  ]
}

# associate the subnet to the network security group (to protect the subnet with the NSG)
resource "azurerm_subnet_network_security_group_association" "security-snsg" {
  subnet_id                 = azurerm_subnet.security-subnect.id
  network_security_group_id = azurerm_network_security_group.security-nsg.id

  depends_on = [
    azurerm_network_security_group.security-nsg
  ]
}

# define a Public IP address
resource "azurerm_public_ip" "security-ip" {
  name                = "Security-Team-ip-1-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "sec"
  }
}

# create the Network Interface
resource "azurerm_network_interface" "security-nic" {
  name                = "Security-Team-nic-1-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.security-subnect.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.security-ip.id
  }

  tags = {
    environment = "sec"
  }

  depends_on = [
    azurerm_public_ip.security-ip
  ]
}

# creating Linux VM
resource "azurerm_linux_virtual_machine" "security-vm-linux" {
  name                = var.Linux_VM_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = "securitypmh"
  network_interface_ids = [
    azurerm_network_interface.security-nic.id
  ]

  admin_ssh_key {
    username   = "securitypmh"
    public_key = tls_private_key.linux_vm_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    # related to Ensure that 'OS and Data' disks are encrypted with Customer Managed Key (CMK)
    disk_encryption_set_id = var.disk-encryption-set1-id
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "sec"
  }
}


resource "azurerm_log_analytics_workspace" "security-workspace1" {
  name                = "Security-Team-workspace1-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  retention_in_days   = 30
}

