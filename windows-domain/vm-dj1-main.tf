# Local variables
locals {
  dj1_fqdn = "${var.ad_dj1_name}.${var.ad_domain_name}"

  dj1_prereq_ad_1 = "Import-Module ServerManager"
  dj1_prereq_ad_2 = "Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools"
  dj1_prereq_ad_3 = "Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools"
  dj1_prereq_ad_4 = "Import-Module ADDSDeployment"
  dj1_prereq_ad_5 = "Import-Module DnsServer"

  dj1_credentials_1 = "$User = '${var.ad_admin_username}@${var.ad_domain_name}'"
  dj1_credentials_2 = "$PWord = ConvertTo-SecureString -String ${var.ad_admin_password} -AsPlainText -Force"
  dj1_credentials_3 = "$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord"
  dj1_install_ad_1  = "add-computer -domainname ${var.ad_domain_name} -Credential $Credential -restart -force"

  dj1_shutdown_command   = "shutdown -r -t 10"
  dj1_exit_code_hack     = "exit 0"
  dj1_powershell_command = "${local.dj1_prereq_ad_1}; ${local.dj1_prereq_ad_2}; ${local.dj1_prereq_ad_3}; ${local.dj1_prereq_ad_4}; ${local.dj1_prereq_ad_5}; ${local.dj1_credentials_1}; ${local.dj1_credentials_2}; ${local.dj1_credentials_3}; ${local.dj1_install_ad_1}; ${local.dj1_shutdown_command}; ${local.dj1_exit_code_hack}"
}

# Create the security group to access dj1
resource "azurerm_network_security_group" "dj1-vm-nsg" {
  depends_on = [azurerm_resource_group.network-rg]

  name                = "${var.ad_dj1_name}-nsg"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name

  security_rule {
    name                       = "AllowRDP"
    description                = "Allow RDP"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allowssh"
    description                = "Allow ssh"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allowhttps"
    description                = "Allow https"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowWRM"
    description                = "Allow wrm"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  tags = {
    application = var.app_name
    environment = var.environment
  }
}

# Get an External IP for dj1
resource "azurerm_public_ip" "dj1-eip" {
  depends_on = [azurerm_resource_group.network-rg]

  name                = "${var.ad_dj1_name}-eip"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name
  allocation_method   = "Static"

  tags = {
    application = var.app_name
    environment = var.environment
  }
}

# Create a NIC for dj1
resource "azurerm_network_interface" "dj1-nic" {
  depends_on = [azurerm_public_ip.dj1-eip]

  name                    = "${var.ad_dj1_name}-nic"
  location                = azurerm_resource_group.network-rg.location
  resource_group_name     = azurerm_resource_group.network-rg.name
  internal_dns_name_label = var.ad_dj1_name
  # the dns server is the domain controller 
  dns_servers = local.dns_dc_servers

  ip_configuration {
    name                          = "${var.ad_dj1_name}-ip-config"
    subnet_id                     = azurerm_subnet.network-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ad_dj1_ip_address
    public_ip_address_id          = azurerm_public_ip.dj1-eip.id
  }

  tags = {
    application = var.app_name
    environment = var.environment
  }
}

# dj1 virtual machine
resource "azurerm_windows_virtual_machine" "dj1-vm" {

  name                = "${var.ad_dj1_name}-vm"
  computer_name       = "${var.ad_dj1_name}-vm"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name

  size           = var.dj1_vm_size
  admin_username = var.ad_admin_username
  admin_password = var.ad_admin_password
  license_type   = var.dj1_license_type

  network_interface_ids = [azurerm_network_interface.dj1-nic.id]

  os_disk {
    name                 = "${var.ad_dj1_name}-vm-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    #sku       = var.windows_2022_sku
    sku     = var.windows_2016_sku
    version = "latest"
  }

  enable_automatic_updates = true
  provision_vm_agent       = true

  tags = {
    application = var.app_name
    environment = var.environment
  }
}

# dj1 virtual machine extension - Install and configure AD
resource "azurerm_virtual_machine_extension" "dj1-vm-extension" {
  depends_on = [azurerm_windows_virtual_machine.dj1-vm]

  name                 = "${var.ad_dj1_name}-vm-active-directory"
  virtual_machine_id   = azurerm_windows_virtual_machine.dj1-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings             = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -Command \"${local.dj1_powershell_command}\""
  }
  SETTINGS

  tags = {
    application = var.app_name
    environment = var.environment
  }
}
