# ============================================================================
# AZURE STATIC WEB APPS CONFIGURATION
# ============================================================================

# Random string for Static Web App name uniqueness
resource "random_string" "staticweb_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Azure Static Web App
resource "azurerm_static_web_app" "web_cdp" {
  name                = "${local.static_web_name}-${random_string.staticweb_suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.static_web_app_location  # Use specific location for Static Web Apps
  sku_tier            = var.static_web_app_sku_tier
  sku_size            = var.static_web_app_sku_size

  tags = local.common_tags
}

# Custom Domain for Static Web App (only create if enabled and DNS is configured)
resource "azurerm_static_web_app_custom_domain" "web_cdp" {
  count             = var.enable_custom_domain ? 1 : 0
  static_web_app_id = azurerm_static_web_app.web_cdp.id
  domain_name       = var.static_web_app_custom_domain
  validation_type   = "cname-delegation"
}

# ============================================================================
# STATIC WEB APP FUNCTION APP (Optional)
# ============================================================================

# If you need backend functions for your static web app
resource "azurerm_static_web_app_function_app_registration" "web_cdp" {
  count              = var.enable_static_web_functions ? 1 : 0
  static_web_app_id  = azurerm_static_web_app.web_cdp.id
  function_app_id    = var.function_app_id  # You would need to create a Function App separately
}

# ============================================================================
# STATIC WEB APP ENVIRONMENT VARIABLES (Optional)
# ============================================================================

# Environment variables for the static web app
locals {
  static_web_app_settings = {
    "BLOB_STORAGE_CONNECTION_STRING" = azurerm_storage_account.main.primary_connection_string
    "BLOB_CONTAINER_NAME"           = azurerm_storage_container.containers["main"].name
    "STATIC_WEB_CONTAINER_NAME"     = azurerm_storage_container.containers["static-web"].name
    "ENVIRONMENT"                   = var.environment
    "PROJECT"                       = local.project
    # "API_BASE_URL"                  = "https://${local.golang_api.latest_revision_fqdn}"
    # "NODEJS_API_URL"                = "https://${local.nodejs_api.latest_revision_fqdn}"
  }
}

# Note: Azure Static Web Apps environment variables are typically configured through
# the Azure portal or GitHub Actions deployment pipeline rather than Terraform.
# The above locals are provided for reference and can be used in your deployment scripts.