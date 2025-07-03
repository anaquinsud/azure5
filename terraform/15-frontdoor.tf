# ============================================================================
# AZURE FRONT DOOR WITH BLOB STORAGE
# terraform/15-frontdoor.tf
# ============================================================================

# Random string for Front Door profile name uniqueness
resource "random_string" "frontdoor_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Azure Front Door Profile
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "${local.base_name}-fd-${random_string.frontdoor_suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Standard_AzureFrontDoor"
  
  tags = local.common_tags
}

# Front Door Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "${local.base_name}-fd-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  
  tags = local.common_tags
}

# Origin Group for Blob Storage
resource "azurerm_cdn_frontdoor_origin_group" "blob" {
  name                     = "blob-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  session_affinity_enabled = false

  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10

  health_probe {
    interval_in_seconds = 100
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }
}

# Origin for Static Website Blob Storage
resource "azurerm_cdn_frontdoor_origin" "blob_static" {
  name                          = "blob-static-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.blob.id
  enabled                       = true

  # Static Website endpoint
  host_name                     = azurerm_storage_account.main.primary_web_host
  http_port                     = 80
  https_port                    = 443
  origin_host_header            = azurerm_storage_account.main.primary_web_host
  priority                      = 1
  weight                        = 1000
  certificate_name_check_enabled = true
}

# Route for default traffic
resource "azurerm_cdn_frontdoor_route" "default" {
  name                      = "default-route"
  cdn_frontdoor_endpoint_id = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.blob.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.blob_static.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true

  cache {
    query_string_caching_behavior = "IgnoreQueryString"
    query_strings                 = []
    compression_enabled           = true
    content_types_to_compress = [
      "application/eot",
      "application/font",
      "application/font-sfnt",
      "application/javascript",
      "application/json",
      "application/opentype",
      "application/otf",
      "application/pkcs7-mime",
      "application/truetype",
      "application/ttf",
      "application/vnd.ms-fontobject",
      "application/xhtml+xml",
      "application/xml",
      "application/xml+rss",
      "application/x-font-opentype",
      "application/x-font-truetype",
      "application/x-font-ttf",
      "application/x-httpd-cgi",
      "application/x-mpegurl",
      "application/x-opentype",
      "application/x-otf",
      "application/x-perl",
      "application/x-ttf",
      "application/x-javascript",
      "font/eot",
      "font/ttf",
      "font/otf",
      "font/opentype",
      "image/svg+xml",
      "text/css",
      "text/csv",
      "text/html",
      "text/javascript",
      "text/js",
      "text/plain",
      "text/richtext",
      "text/tab-separated-values",
      "text/xml",
      "text/x-script",
      "text/x-component",
      "text/x-java-source"
    ]
  }
}

# Security Policy (WAF)
resource "azurerm_cdn_frontdoor_security_policy" "main" {
  name                     = "${local.base_name}-waf-policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.main.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.main.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}

# WAF Policy
resource "azurerm_cdn_frontdoor_firewall_policy" "main" {
  name                              = "${replace(local.base_name, "-", "")}wafpolicy"
  resource_group_name               = azurerm_resource_group.main.name
  sku_name                          = azurerm_cdn_frontdoor_profile.main.sku_name
  enabled                           = true
  mode                              = "Prevention"
  redirect_url                      = "https://www.microsoft.com"
  custom_block_response_status_code = 403
  custom_block_response_body        = "You have been blocked."

  # Managed rules
  managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"
    action  = "Block"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }

  tags = local.common_tags
}

# ============================================================================
# STORAGE ACCOUNT STATIC WEBSITE CONFIGURATION
# ============================================================================

# Enable static website hosting on storage account
resource "azurerm_storage_account_static_website" "main" {
  storage_account_id = azurerm_storage_account.main.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

# ============================================================================
# LOCALS FOR FRONT DOOR CONFIGURATION
# ============================================================================

locals {
  # Front Door configuration
  frontdoor_name = "${local.base_name}-fd"
  
  # Front Door endpoints
  frontdoor_endpoints = {
    main = {
      name = "main-endpoint"
      origins = {
        blob_static = {
          host_name = azurerm_storage_account.main.primary_web_host
          priority  = 1
          weight    = 1000
        }
      }
    }
  }
}