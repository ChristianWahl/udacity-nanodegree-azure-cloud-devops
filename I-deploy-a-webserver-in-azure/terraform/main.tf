provider "azurerm" {
  features {}
}

resource "random_string" "fqdn" {
  length = 6
  special = false
  upper = false
  number = false
}

resource "azurerm_resource_group" "main" {
  name = "${var.prefix}-resources"
  location = var.location
  tags = {
    name = var.prefix
  }
}

resource "azurerm_virtual_network" "main" {
  name = "${var.prefix}-network"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    name = var.prefix
  }
}

resource "azurerm_subnet" "internal" {
  name = "internal"
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  count = var.instance_count
  name = "${var.prefix}-nic${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  tags = {
    name = var.prefix
  }

  ip_configuration {
    name = "ipconfig${count.index}"
    subnet_id = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "pip" {
  name = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  allocation_method = "Static"
  domain_name_label = random_string.fqdn.result
  tags = {
    name = var.prefix
  }
}

resource "azurerm_availability_set" "avset" {
  name = "${var.prefix}avset"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  platform_fault_domain_count = 2
  platform_update_domain_count = 2
  managed = true
  tags = {
    name = var.prefix
  }
}

resource "azurerm_network_security_group" "main" {
  name = "webserver-sg"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    name = var.prefix
  }

  security_rule {
    name = "allow-all-inbound-internal"
    description = "Allow all inbound traffic for VMs on the subnet"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name = "http-access-rule"
    description = "Allow all inbound traffic from the internet for port 80 (HTTP)"
    priority = 200
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "deny-inbound"
    description = "Deny all inbound traffic from the Internet"
    priority = 300
    direction = "Inbound"
    access = "Deny"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  count = var.instance_count
  network_interface_id = element(azurerm_network_interface.main.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_lb" "loadbalancer" {
  name = "${var.prefix}-lb"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    name = var.prefix
  }

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "loadbalancer" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id = azurerm_lb.loadbalancer.id
  name = "BackEndAddressPool"
}

resource "azurerm_lb_nat_rule" "tcp" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id = azurerm_lb.loadbalancer.id
  name = "HTTPAccess"
  protocol = "Tcp"
  frontend_port = "80"
  backend_port = "80"
  frontend_ip_configuration_name = azurerm_lb.loadbalancer.frontend_ip_configuration[0].name
}

resource "azurerm_network_interface_nat_rule_association" "natrule" {
  count = var.instance_count
  network_interface_id = element(azurerm_network_interface.main.*.id, count.index)
  ip_configuration_name = "ipconfig${count.index}"
  nat_rule_id = element(azurerm_lb_nat_rule.tcp.*.id, count.index)
}


resource "azurerm_network_interface_backend_address_pool_association" "loadbalancer" {
  count = var.instance_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.loadbalancer.id
  ip_configuration_name = "ipconfig${count.index}"
  network_interface_id = azurerm_network_interface.main[count.index].id
}

resource "azurerm_linux_virtual_machine" "main" {
  count = var.instance_count
  name = "${var.prefix}-vm${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  size = var.vm_size
  admin_username = var.vm_user
  admin_password = var.vm_password
  availability_set_id = azurerm_availability_set.avset.id
  disable_password_authentication = false
  network_interface_ids = [element(azurerm_network_interface.main.*.id, count.index)]
  tags = {
    name = var.prefix
  }

  source_image_id = var.vm_id

  os_disk {
    storage_account_type = var.vm_disk_type
    caching = "ReadWrite"
  }
}
