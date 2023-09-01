output "public_ip" {
  value = azurerm_network_interface.nic.private_ip_address
}

# output "vnet_name" {
#   value = var.vnet.name
# }

# output "vnet_location" {
#   value = var.vnet.location
# }