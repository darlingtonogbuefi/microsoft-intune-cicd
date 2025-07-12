variable "subscription_id" {}

variable "client_id" {}

variable "client_secret" {
  sensitive = true
}

variable "tenant_id" {}

variable "admin_username" {}

variable "admin_password" {
  sensitive = true
}

variable "azure_devops_url" {}

variable "pat_token" {
  sensitive = true
}

variable "agent_name" {
  default = "win-agent-01"
}

variable "agent_pool" {
  default = "default"
}

variable "azure_devops_sp_object_id" {}
