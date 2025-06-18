# ============================================================================
# AZURE LOAD BALANCER (Updated for VMSS)
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

# NAT Pool for SSH access to VMSS instances
resource "azurerm_lb_nat_pool" "ssh" {
  count                          = var.enable_vmss_ssh_access ? 1 : 0
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "ssh-nat-pool"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50099
  backend_port                   = 22
  frontend_ip_configuration_name = "frontend-ip"
}
