# ============================================================================
# AZURE BASTION CONFIGURATION
# ============================================================================

# Bastion Subnet (required for Azure Bastion)
resource "azurerm_subnet" "bastion" {
  count                = var.enable_bastion ? 1 : 0
  name                 = "AzureBastionSubnet"  # Name is fixed by Azure
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.254.0/24"]  # Dedicated subnet for Bastion
}

# Public IP for Bastion Host
resource "azurerm_public_ip" "bastion" {
  count               = var.enable_bastion ? 1 : 0
  name                = local.bastion_pip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

# Azure Bastion Host
resource "azurerm_bastion_host" "main" {
  count               = var.enable_bastion ? 1 : 0
  name                = local.bastion_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = var.bastion_sku
  scale_units         = var.bastion_scale_units

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }

  # Enable features based on SKU (Standard SKU only)
  file_copy_enabled      = var.bastion_sku == "Standard" ? var.bastion_file_copy_enabled : false
  copy_paste_enabled     = var.bastion_copy_paste_enabled
  ip_connect_enabled     = var.bastion_sku == "Standard" ? var.bastion_ip_connect_enabled : false
  shareable_link_enabled = var.bastion_sku == "Standard" ? var.bastion_shareable_link_enabled : false
  tunneling_enabled      = var.bastion_sku == "Standard" ? var.bastion_tunneling_enabled : false

  tags = local.common_tags
}

# ============================================================================
# NETWORK SECURITY GROUP FOR BASTION
# ============================================================================

# NSG for Bastion Subnet (optional but recommended)
resource "azurerm_network_security_group" "bastion" {
  count               = var.enable_bastion ? 1 : 0
  name                = local.nsg_bastion_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Dynamic security rules for Bastion
  dynamic "security_rule" {
    for_each = local.bastion_security_rules
    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = lookup(security_rule.value, "destination_port_range", null)
      destination_port_ranges    = lookup(security_rule.value, "destination_port_ranges", null)
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = local.common_tags
}

# Associate NSG with Bastion subnet
resource "azurerm_subnet_network_security_group_association" "bastion" {
  count                     = var.enable_bastion ? 1 : 0
  subnet_id                 = azurerm_subnet.bastion[0].id
  network_security_group_id = azurerm_network_security_group.bastion[0].id
}