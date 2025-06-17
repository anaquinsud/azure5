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


# # ============================================================================
# # CONTAINER APPS OUTPUTS (UPDATED FOR PRIVATE ACCESS)
# # ============================================================================

# output "container_app_environment_id" {
#   description = "ID of the Container Apps environment"
#   value       = azurerm_container_app_environment.main.id
# }

# output "container_app_environment_default_domain" {
#   description = "Default domain of the private Container Apps environment"
#   value       = azurerm_container_app_environment.main.default_domain
# }

# output "container_app_environment_static_ip" {
#   description = "Static IP address of the private Container Apps environment"
#   value       = azurerm_container_app_environment.main.static_ip_address
# }

# # Individual app outputs for backward compatibility (now private URLs)
# output "golang_api_fqdn" {
#   description = "Private FQDN of the Golang API Container App"
#   value       = azurerm_container_app.apps["golang-api"].latest_revision_fqdn
# }

# output "nodejs_api_fqdn" {
#   description = "Private FQDN of the Node.js API Container App" 
#   value       = azurerm_container_app.apps["nodejs-api"].latest_revision_fqdn
# }

# # All container apps output (updated for private access)
# output "container_apps" {
#   description = "All Container Apps information (private access)"
#   value = {
#     for name, app in azurerm_container_app.apps : 
#     name => {
#       id           = app.id
#       name         = app.name
#       private_fqdn = app.latest_revision_fqdn
#       private_url  = "https://${app.latest_revision_fqdn}"
#       note         = "This is a private URL accessible only from within the VNet"
#     }
#   }
# }

# output "container_apps_access_info" {
#   description = "Information about accessing private Container Apps"
#   value = {
#     access_method = "Private network access only"
#     accessible_from = [
#       "Virtual machines in the same VNet",
#       "Resources connected via VNet peering",
#       "On-premises networks connected via VPN/ExpressRoute",
#       "Azure Bastion (if enabled)"
#     ]
#     static_ip = azurerm_container_app_environment.main.static_ip_address
#     default_domain = azurerm_container_app_environment.main.default_domain
#   }
# }