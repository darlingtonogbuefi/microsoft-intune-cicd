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

  custom_data = base64encode(<<-EOF
    <powershell>
    # Install basic tools
    Write-Host "Installing Azure CLI..."
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile azurecli.msi
    Start-Process msiexec.exe -ArgumentList '/i', 'azurecli.msi', '/quiet', '/norestart' -NoNewWindow -Wait
    Remove-Item -Force azurecli.msi

    Write-Host "Installing Python..."
    Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe -OutFile python-installer.exe
    Start-Process python-installer.exe -ArgumentList '/quiet', 'InstallAllUsers=1', 'PrependPath=1' -NoNewWindow -Wait
    Remove-Item -Force python-installer.exe

    Write-Host "Installing Pester..."
    Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser

    Write-Host "Windows Server 2022 VM setup complete"
    </powershell>
  EOF
  )
}

resource "azurerm_key_vault" "kv" {
  name                        = "IntuneCICDKeyVault534"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  public_network_access_enabled = true

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.azure_devops_sp_object_id

    secret_permissions = [
      "Get",
      "List"
    ]
  }
}
