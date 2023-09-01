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

resource "azurerm_network_interface" "poofoo266" {
  name                = "poofoo266"
  resource_group_name = "DEV-RESOURCES"
  location            = "eastus"

  ip_configuration {
    name                          = "ipconfig1"
    primary                       = true
    private_ip_address            = "10.0.1.5"
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = azurerm_public_ip.poofoo-ip.id
    subnet_id                     = azurerm_subnet.subnet.id
  }
}

resource "azurerm_public_ip" "poofoo-ip" {
  allocation_method   = "Dynamic"
  location            = "eastus"
  name                = "poofoo-ip"
  resource_group_name = "DEV-RESOURCES"
}

resource "azurerm_network_security_group" "poofoo-nsg" {
  location            = "eastus"
  name                = "poofoo-nsg"
  resource_group_name = "DEV-RESOURCES"

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.poofoo-nsg.id
}

resource "azurerm_linux_virtual_machine" "poofoo" {
  name                  = "poofoo"
  location              = "eastus"
  size                  = "Standard_B1s"
  resource_group_name   = "DEV-RESOURCES"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.poofoo266.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "canonical"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
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