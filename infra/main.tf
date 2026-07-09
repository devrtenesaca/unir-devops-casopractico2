resource "azurerm_resource_group" "rg_caso2" {
  name     = "${var.prefix}-devops"
  location = var.location
  tags = {
    environment = "unir-caso2-devops"
    created_by  = "terraform"
  }

}



resource "azurerm_virtual_network" "vnet_caso2" {
  name                = "${var.prefix}-vnet-devops"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_caso2.name
  address_space       = ["10.10.0.0/16"]
  tags                = var.tags
}
resource "azurerm_subnet" "subnet_caso2" {
  name                 = "${var.prefix}-subnet-devops"
  resource_group_name  = azurerm_resource_group.rg_caso2.name
  virtual_network_name = azurerm_virtual_network.vnet_caso2.name
  address_prefixes     = ["10.10.1.0/24"]
}

#create container registry
resource "azurerm_container_registry" "acr_registry" {
  name                = "acrcasoproctico01"
  resource_group_name = azurerm_resource_group.rg_caso2.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true

}
# create network security group
resource "azurerm_network_security_group" "nsg_caso2" {
  name                = "${var.prefix}-nsg-devops"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_caso2.name
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#section virtual machine
resource "azurerm_public_ip" "pip_caso2" {
  name                = "${var.prefix}-pip-devops"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_caso2.name
  allocation_method   = "Static"   # Esto asegura que la IP no cambie y aparezca rápido
  sku                 = "Standard" # Recomendado para evitar problemas de compatibilidad
}

resource "azurerm_network_interface" "nic_caso2" {
  name                = "${var.prefix}-nic-devops"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_caso2.name

  ip_configuration {
    name                          = "${var.prefix}-ipconfig-devops"
    subnet_id                     = azurerm_subnet.subnet_caso2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_caso2.id
  }
}


resource "azurerm_linux_virtual_machine" "vm_caso2" {
  name                  = "${var.prefix}-vm-devops"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg_caso2.name
  network_interface_ids = [azurerm_network_interface.nic_caso2.id]
  size                  = "Standard_D2s_v3"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_username = "opensip"
  admin_password = "P@ssw0rd1234!"

  disable_password_authentication = false

  custom_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y software-properties-common
              sudo add-apt-repository --yes --update ppa:ansible/ansible
              sudo apt-get install -y ansible podman
              EOF
  )
}

#associate the network security group with the network interface

resource "azurerm_network_interface_security_group_association" "nsg_assoc_caso2" {
  network_interface_id      = azurerm_network_interface.nic_caso2.id
  network_security_group_id = azurerm_network_security_group.nsg_caso2.id
}






