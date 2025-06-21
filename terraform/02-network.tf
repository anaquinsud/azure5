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
  for_each = toset(var.availability_zones)
  
  name                 = "${local.subnet_private_name_prefix}-zone${each.key}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.private_subnet_cidrs[each.key]]
}

# Container Apps Subnet (required for private Container Apps Environment)
resource "azurerm_subnet" "container_apps" {
  name                 = local.subnet_container_apps_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.container_apps_subnet_cidr]
  
  # ไม่ต้อง delegate สำหรับ Container Apps Environment
  # Container Apps Environment จะทำการ delegate subnet ให้เองอัตโนมัติ
}

# NAT Gateway Subnet (only created when NAT is enabled)
resource "azurerm_subnet" "nat" {
  count                = var.enable_nat_gateway ? 1 : 0
  name                 = local.subnet_nat_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

# ============================================================================
# PRIVATE DNS ZONE FOR CONTAINER APPS
# ============================================================================

# Private DNS Zone for Container Apps Environment
resource "azurerm_private_dns_zone" "container_apps" {
  name                = azurerm_container_app_environment.main.default_domain
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

# Link Private DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "container_apps" {
  name                  = "${local.base_name}-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.container_apps.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
  tags                  = local.common_tags
}

# A Record for Container Apps Environment
resource "azurerm_private_dns_a_record" "container_apps_wildcard" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.container_apps.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [azurerm_container_app_environment.main.static_ip_address]
  tags                = local.common_tags
}