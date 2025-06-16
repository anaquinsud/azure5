# ============================================================================
# AZURE BLOB STORAGE
# ============================================================================

# Random string for storage account name uniqueness
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "${local.storage_name}${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  tags                     = local.common_tags
}

# Storage Containers (Loop)
resource "azurerm_storage_container" "containers" {
  for_each = local.storage_containers
  
  name                  = "${local.project}-${local.environment}-${each.key}"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = each.value.access_type
}