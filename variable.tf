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

variable "agent_name" {
  default = "win-agent-01"
}

variable "agent_pool" {
  default = "default"
}


