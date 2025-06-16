# ============================================================================
# AZURE CONTAINER REGISTRY
# ============================================================================

# Random string for ACR name uniqueness
resource "random_string" "acr_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "${local.acr_name}${random_string.acr_suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = local.common_tags
}

# ============================================================================
# CONTAINER APPS ENVIRONMENT
# ============================================================================

# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                       = local.aca_env_name
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = local.common_tags
}

# ============================================================================
# CONTAINER APPS (USING LOOPS)
# ============================================================================

# Container Apps (Loop)
resource "azurerm_container_app" "apps" {
  for_each = local.container_apps
  
  name                         = "ca-${local.base_name}-${each.key}"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode                = "Single"

  # ACR Registry Configuration
  registry {
    server               = azurerm_container_registry.main.login_server
    username             = azurerm_container_registry.main.admin_username
    password_secret_name = "acr-password"
  }

  # ACR Password Secret
  secret {
    name  = "acr-password"
    value = azurerm_container_registry.main.admin_password
  }

  template {
    container {
      name   = each.key
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory

      # Dynamic environment variables
      dynamic "env" {
        for_each = each.value.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }
    }

    min_replicas = each.value.min_replicas
    max_replicas = each.value.max_replicas
  }

  # Conditional ingress (only for services with target_port)
  dynamic "ingress" {
    for_each = each.value.target_port != null ? [1] : []
    content {
      allow_insecure_connections = false
      external_enabled           = var.container_apps_external_enabled
      target_port                = each.value.target_port
      
      # IP Security Restrictions (only if external is enabled)
      dynamic "ip_security_restriction" {
        for_each = var.container_apps_external_enabled ? [1] : []
        content {
          name             = "AllowVMSubnet"
          ip_address_range = var.vm_subnet_cidr
          action           = "Allow"
        }
      }

      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }

  tags = local.common_tags
}

# ============================================================================
# LEGACY REFERENCES (for backward compatibility)
# ============================================================================

# Create local references for existing outputs that expect specific resource names
locals {
  # Map the loop-created resources to expected names for backward compatibility
  golang_api = azurerm_container_app.apps["golang-api"]
  nodejs_api = azurerm_container_app.apps["nodejs-api"]
}