variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "agent_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "vnet_address_space" {
  description = "Address space for virtual network"
  type        = list(string)
}

variable "snet_address_space" {
  description = "Address prefixes for subnet"
  type        = list(string)
}

variable "disk_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
  sensitive   = true
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Azure client ID (Service Principal)"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Azure client secret (Service Principal)"
  type        = string
  sensitive   = true
}
