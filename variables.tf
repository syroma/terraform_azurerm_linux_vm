variable "location" {
  description = "site location"
  default     = "East US"
}
variable "env_prefix" {
  description = "default environment"
  default     = "dev"
}

# ip info
variable "address_space" {
  description = "overall cidr space"
  default     = "10.0.0.0/16"
}
variable "address_prefixes" {
  description = "subnet address"
  default     = "10.0.1.0/24"
}

# vm
variable "admin_username" {
  description = "user name"
  default     = "adminuser"
}
variable "vm_size" {
  description = "virtual machine size"
  default     = "Standard_B1s"
}
variable "disk_caching" {
  description = "disk caching style"
  default     = "ReadWrite"
}
variable "storage_account_type" {
  description = "storage type"
  default     = "Standard_LRS"
}

# container
# variable "account_kind" {}
# variable "account_tier" {}
# variable "account_replication_type" {}
# variable "container_access_type" {}

variable "ip_name" {
  description = "IP address placement"
  default     = "internal"
}
variable "private_ip_address_allocation" {
  description = "Static or Dynamic"
  default     = "Dynamic"
}

# variable "resource_group" {}
# variable "vnet" {}

#variable "network_interface_ids" {}

variable "vm_map" {
  type = map(object({
    name           = string
    size           = string
    admin_password = string
  }))
  default = {
    "vm1" = {
      admin_password = "Password1"
      name           = "FTP-Serv-01"
      size           = "Standard_B1s"
    }
    "vm2" = {
      admin_password = "Password2"
      name           = "MailServ-01"
      size           = "Standard_B1s"
    }
    "vm3" = {
      admin_password = "Password3"
      name           = "SSH-Serv-01"
      size           = "Standard_B1s"
    }
  }
}
