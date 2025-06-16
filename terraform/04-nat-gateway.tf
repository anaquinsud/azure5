# ============================================================================
# NAT GATEWAY (CONDITIONAL)
# ============================================================================

# Public IP for NAT Gateway (only created when NAT is enabled)
resource "azurerm_public_ip" "nat" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = local.nat_pip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# NAT Gateway (only created when enabled)
resource "azurerm_nat_gateway" "main" {
  count                   = var.enable_nat_gateway ? 1 : 0
  name                    = local.nat_name
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = local.common_tags
}

# Associate Public IP with NAT Gateway (only when NAT is enabled)
resource "azurerm_nat_gateway_public_ip_association" "main" {
  count                = var.enable_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.main[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

# Associate NAT Gateway with private subnet (only when NAT is enabled)
resource "azurerm_subnet_nat_gateway_association" "private" {
  count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.main[0].id
}