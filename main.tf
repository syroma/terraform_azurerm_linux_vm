resource "azurerm_resource_group" "rg" {
  name     = "${var.env_prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.env_prefix}-network"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.address_space]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.env_prefix}-subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.address_prefixes]
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.env_prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = var.ip_name
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = var.private_ip_address_allocation
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "vm_public_ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}
#--------------

module "vm_pc" {
  source               = "./modules/vm"
  env_prefix           = var.env_prefix
  resource_group       = azurerm_resource_group.rg
  vnet                 = azurerm_virtual_network.vnet
  admin_username       = var.admin_username
  vm_size              = var.vm_size
  disk_caching         = var.disk_caching
  storage_account_type = var.storage_account_type
  network_interface    = azurerm_network_interface.nic.id
}

#--------------
# resource "azurerm_network_security_group" "nsg" {
#   name                = "${var.env_prefix}-nsg"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_network_security_rule" "nsr-1" {
#   name                        = "ssh"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "22"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.rg.name
#   network_security_group_name = azurerm_network_security_group.nsg.name
# }

# resource "azurerm_network_interface_security_group_association" "nic_sec_assoc" {
#   network_interface_id      = azurerm_network_interface.nic.id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }

# resource "azurerm_linux_virtual_machine" "example" {
#   name                = "${var.env_prefix}-machine"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   size                = var.vm_size
#   admin_username      = var.admin_username
#   network_interface_ids = [
#     azurerm_network_interface.nic.id
#   ]

#   admin_ssh_key {
#     username   = var.admin_username
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   os_disk {
#     caching              = var.disk_caching
#     storage_account_type = var.storage_account_type
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-focal"
#     sku       = "20_04-lts"
#     version   = "latest"
#   }
# }
#-------------------
# resource "azurerm_storage_account" "stg" {
#   name                     = "stsyaccount"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_kind             = var.account_kind
#   account_tier             = var.account_tier
#   account_replication_type = var.account_replication_type

#   tags = {
#     environment = "${var.env_prefix}"
#   }
# }

# resource "azurerm_storage_container" "stgcntr" {
#   name                  = "${var.env_prefix}-stcontainer"
#   storage_account_name  = azurerm_storage_account.stg.name
#   container_access_type = var.container_access_type
# }