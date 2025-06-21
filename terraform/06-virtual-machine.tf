# ============================================================================
# VIRTUAL MACHINE (LOOP-BASED MULTI-ZONE)
# ============================================================================

# Public IP for VMs (only created when enabled) - Using Loop
resource "azurerm_public_ip" "vm" {
  for_each = var.enable_vm_public_ip ? local.virtual_machines : {}
  
  name                = each.value.pip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [each.value.zone]
  
  tags = merge(local.common_tags, each.value.tags)
}

# Network Interface for VMs - Using Loop
resource "azurerm_network_interface" "vm" {
  for_each = local.virtual_machines
  
  name                = each.value.nic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private[each.value.subnet_key].id
    private_ip_address_allocation = "Dynamic"
    # Conditional public IP assignment
    public_ip_address_id          = var.enable_vm_public_ip ? azurerm_public_ip.vm[each.key].id : null
  }

  tags = merge(local.common_tags, each.value.tags)
}

# Virtual Machines with zone deployment - Using Loop
resource "azurerm_linux_virtual_machine" "main" {
  for_each = local.virtual_machines
  
  name                = each.value.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = each.value.size
  admin_username      = each.value.admin_username
  zone                = each.value.zone

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm[each.key].id,
  ]

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = each.value.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = each.value.disk_size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = merge(local.common_tags, each.value.tags)
}