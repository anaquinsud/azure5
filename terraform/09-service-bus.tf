# ============================================================================
# AZURE SERVICE BUS
# ============================================================================

# Random string for Service Bus namespace uniqueness
resource "random_string" "servicebus_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Service Bus Namespace
resource "azurerm_servicebus_namespace" "main" {
  name                = "${local.servicebus_name}-${random_string.servicebus_suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  tags                = local.common_tags
}

# Service Bus Queues (Loop)
resource "azurerm_servicebus_queue" "queues" {
  for_each = local.servicebus_queues
  
  name         = each.key
  namespace_id = azurerm_servicebus_namespace.main.id
  
  enable_partitioning      = each.value.enable_partitioning
  max_size_in_megabytes   = each.value.max_size_in_megabytes
  default_message_ttl     = each.value.default_message_ttl
  lock_duration           = each.value.lock_duration
}