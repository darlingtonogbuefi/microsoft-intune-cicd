provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "devops-agent-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "agent-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "agent-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "agent-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "agent-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WinRM"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "agent-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "agent" {
  name                  = var.agent_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B2s"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  license_type          = "Windows_Server"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "agentosdisk"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "windowsserver"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "psscript" {
  name                 = "setup-environment"
  virtual_machine_id   = azurerm_windows_virtual_machine.agent.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "fileUris": [
        "https://raw.githubusercontent.com/darlingtonogbuefi/microsoft-intune-cicd/main/setup-agentVM-environment.ps1"
      ],
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File setup-agentVM-environment.ps1"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {}
  PROTECTED_SETTINGS

  depends_on = [
    azurerm_windows_virtual_machine.agent
  ]
}

resource "azurerm_key_vault" "kv" {
  name                          = "intunecicdkeyvault"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  purge_protection_enabled      = false
  public_network_access_enabled = true
}
