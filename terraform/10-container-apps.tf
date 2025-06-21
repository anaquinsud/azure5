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
# CONTAINER APPS ENVIRONMENT (PRIVATE)
# ============================================================================

# Container Apps Environment with VNet integration
resource "azurerm_container_app_environment" "main" {
  name                       = local.aca_env_name
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  
  # Make it private by specifying VNet configuration
  infrastructure_subnet_id         = azurerm_subnet.container_apps.id
  internal_load_balancer_enabled   = true  # This makes it private
  
  zone_redundancy_enabled = false

  tags = local.common_tags
}

# ============================================================================
# CONTAINER APPS (USING LOOPS) - NOW PRIVATE
# ============================================================================

# Container Apps (Loop) - Now will be private since environment is private
resource "azurerm_container_app" "apps" {
  for_each = local.container_apps
  
  name                         = "${each.key}"
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

    dynamic "custom_scale_rule" {
      for_each = each.value.scale_rules
      content {
        name             = custom_scale_rule.value.name
        custom_rule_type = custom_scale_rule.value.type
        metadata         = custom_scale_rule.value.metadata
      }
    }
  }

  # Ingress for private access only (no external access)
  dynamic "ingress" {
    for_each = each.value.target_port != null ? [1] : []
    content {
      allow_insecure_connections = false
      external_enabled           = true  # Changed to false for private access only
      target_port                = each.value.target_port
      
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

# # Create local references for existing outputs that expect specific resource names
# locals {
#   # Map the loop-created resources to expected names for backward compatibility
#   golang_api = azurerm_container_app.apps["golang-api"]
#   nodejs_api = azurerm_container_app.apps["nodejs-api"]
# }