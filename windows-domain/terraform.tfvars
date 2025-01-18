company               = "hrouhan"
app_name              = "security team"
environment           = "dev"
#location              = "Germany West Central"
location = "West Europe"
azure-subscription-id = "e9ee8090-9784-42d6-9534-bc1d881eeff6"

network-vnet-cidr   = "10.127.0.0/16"
network-subnet-cidr = "10.127.1.0/24"

ad_domain_name                      = "hrouhan.local"
ad_domain_netbios_name              = "hrouhan"
ad_admin_username                   = "hrouhan"
ad_admin_password                   = "HosseiN110110110"
ad_safe_mode_administrator_password = "R3c0v3ryAcc3ssM0d3"

# example for pass R3c0v3ryAcc3ssM0d3

ad_dc1_name       = "hrz-sec-dc1"
ad_dc1_ip_address = "10.127.1.11"
#dc1_vm_size       = "Standard_B2s"
dc1_vm_size       = "Standard_D4_v3"

ad_dj1_name       = "hrz-sec-dj1"
ad_dj1_ip_address = "10.127.1.12"
#dj1_vm_size       = "Standard_B2s"
dj1_vm_size       = "Standard_D4_v3"
#dj1_vm_size        = "Standard_D8_v3"
