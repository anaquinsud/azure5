# ============================================================================
# AZURE LOAD BALANCER
# ============================================================================

# Public IP for Load Balancer
resource "azurerm_public_ip" "lb" {
  name                = local.lb_pip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# Load Balancer
resource "azurerm_lb" "main" {
  name                = local.lb_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  tags = local.common_tags
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "backend-pool"
}

# Associate VM's Network Interface with Backend Pool
resource "azurerm_lb_backend_address_pool_address" "vm" {
  name                    = "vm-backend-address"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  virtual_network_id      = azurerm_virtual_network.main.id
  ip_address              = azurerm_network_interface.vm.private_ip_address
}

# Health Probes (Loop)
resource "azurerm_lb_probe" "probes" {
  for_each = local.lb_probes
  
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${each.key}-probe"
  port                = each.value.port
  protocol            = each.value.protocol
  request_path        = each.value.request_path
  interval_in_seconds = each.value.interval_in_seconds
  number_of_probes    = each.value.number_of_probes
}

# Load Balancing Rules (Loop)
resource "azurerm_lb_rule" "rules" {
  for_each = local.lb_rules
  
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "${each.key}-rule"
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.probes[each.value.probe_name].id
  disable_outbound_snat          = true
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 15
  load_distribution              = "Default"
}