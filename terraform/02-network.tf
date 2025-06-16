# ============================================================================
# VIRTUAL NETWORK & SUBNETS
# ============================================================================

resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

# Private Subnet for VM
resource "azurerm_subnet" "private" {
  name                 = local.subnet_private_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# NAT Gateway Subnet (only created when NAT is enabled)
resource "azurerm_subnet" "nat" {
  count                = var.enable_nat_gateway ? 1 : 0
  name                 = local.subnet_nat_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}