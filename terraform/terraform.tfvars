location            = "East US"
resource_group_name = "devops-agent-rg"
virtual_network_name = "agent-vnet"
subnet_name          = "agent-subnet"
agent_name           = "devops-agent-vm"
vnet_address_space  = ["10.0.0.0/16"]
snet_address_space  = ["10.0.1.0/24"]
disk_size           = "Standard_B2s"
key_vault_name       = "intunecicdkeyvault"

