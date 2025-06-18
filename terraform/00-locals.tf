# ============================================================================
# LOCAL VALUES FOR NAMING CONVENTION AND CONFIGURATIONS
# ============================================================================

locals {
  # Base naming components
  project     = var.project_name
  environment = var.environment
  location    = var.location_short
  
  # Common naming patterns
  base_name = "${local.project}-${local.environment}-${local.location}"
  
  # Resource Group
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : "${local.base_name}-rg"
  
  # Network Resources
  vnet_name           = "${local.base_name}-vnet"
  subnet_private_name = "${local.base_name}-snet-private"
  subnet_bastion_name = "${local.base_name}-snet-bastion"
  subnet_nat_name     = "${local.base_name}-snet-nat"
  subnet_container_apps_name = "${local.base_name}-snet-container-apps"
  nsg_name           = "${local.base_name}-nsg"
  nsg_bastion_name   = "${local.base_name}-nsg-bastion"
  
  # Virtual Machine
  vm_name           = "${local.base_name}-vm-nginx"
  vm_nic_name       = "${local.base_name}-nic-vm"
  vm_pip_name       = "${local.base_name}-pip-vm"
  
  # Load Balancer
  lb_name           = "${local.base_name}-lb"
  lb_pip_name       = "${local.base_name}-pip-lb"
  
  # NAT Gateway
  nat_name          = "${local.base_name}-ng"
  nat_pip_name      = "${local.base_name}-pip-nat"
  
  # Storage (max 24 chars, no special characters)
  storage_name      = "${replace(local.project, "-", "")}${replace(local.environment, "-", "")}${replace(local.location, "-", "")}st"
  
  # Container Apps
  aca_env_name      = "${local.base_name}-cae"
  acr_name          = "${replace(local.project, "-", "")}${replace(local.environment, "-", "")}${replace(local.location, "-", "")}acr"

  
  # Service Bus
  servicebus_name   = "${local.base_name}-sb"
  
  # Static Web App
  static_web_name   = "${local.base_name}-stapp"
  
  # Log Analytics
  log_analytics_name = "${local.base_name}-log"
  
  # Bastion
  bastion_name      = "${local.base_name}-bas"
  bastion_pip_name  = "${local.base_name}-pip-bastion"
  
  # Common tags with computed values
  common_tags = merge(var.common_tags, {
    Project     = local.project
    Environment = local.environment
    Location    = local.location
  })
  
  # ============================================================================
  # SERVICE BUS QUEUES CONFIGURATION
  # ============================================================================
  
  servicebus_queues = {
    "cdp-queue-survey-tracking" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "P14D"  # 14 days
      lock_duration           = "PT30S" # 30 seconds
    }
    "crm-otp-queue" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
  }
  
  # ============================================================================
  # CONTAINER APPS CONFIGURATION
  # ============================================================================
  
  container_apps = {
    "golang-api" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.5
      memory       = "1Gi"
      min_replicas = 3
      max_replicas = 9
      target_port  = 80
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    "nodejs-api" = {
      image        = "nginx:latest"
      cpu          = 0.5
      memory       = "1Gi"
      min_replicas = 3
      max_replicas = 9
      target_port  = 80
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "nodejs"
      }
    }
  }
  
  # ============================================================================
  # STORAGE CONTAINERS CONFIGURATION
  # ============================================================================
  
  storage_containers = {
    "main" = {
      access_type = "private"
    }
    "static-web" = {
      access_type = "blob"
    }
  }
  
  # ============================================================================
  # NETWORK SECURITY RULES CONFIGURATION
  # ============================================================================
  
  security_rules = {
    "Allow-HTTP-From-LB" = {
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
    }
    "Allow-HTTPS-From-LB" = {
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
    }
    "Allow-HTTP-Internet" = {
      priority                   = 1003
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    "Allow-HTTPS-Internet" = {
      priority                   = 1004
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    "Allow-SSH" = {
      priority                   = 1005
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = var.allowed_ssh_cidr
      destination_address_prefix = "*"
      enabled                    = var.enable_vm_public_ip
    }
    "Deny-All-Inbound" = {
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
  
  # Filter enabled security rules only
  enabled_security_rules = {
    for name, rule in local.security_rules : 
    name => rule if lookup(rule, "enabled", true)
  }
  
  # ============================================================================
  # LOAD BALANCER CONFIGURATION
  # ============================================================================
  
  lb_probes = {
    "http" = {
      port                = 80
      protocol            = "Http"
      request_path        = "/"
      interval_in_seconds = 15
      number_of_probes    = 2
    }
    "https" = {
      port                = 443
      protocol            = "Tcp"
      request_path        = null
      interval_in_seconds = 15
      number_of_probes    = 2
    }
  }
  
  lb_rules = {
    "http" = {
      frontend_port   = 80
      backend_port    = 80
      protocol        = "Tcp"
      probe_name      = "http"
    }
    "https" = {
      frontend_port   = 443
      backend_port    = 443
      protocol        = "Tcp"
      probe_name      = "https"
    }
  }
  
  # ============================================================================
  # BASTION SECURITY RULES CONFIGURATION
  # ============================================================================
  
  bastion_security_rules = {
    "AllowHttpsInbound" = {
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
    "AllowGatewayManagerInbound" = {
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "*"
    }
    "AllowAzureLoadBalancerInbound" = {
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
    }
    "AllowBastionHostCommunication" = {
      priority                   = 1003
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_ranges    = ["8080", "5701"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
    "AllowSshRdpOutbound" = {
      priority                   = 1000
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_ranges    = ["22", "3389"]
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
    }
    "AllowAzureCloudOutbound" = {
      priority                   = 1001
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureCloud"
    }
    "AllowBastionCommunication" = {
      priority                   = 1002
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_ranges    = ["8080", "5701"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
    "AllowGetSessionInformation" = {
      priority                   = 1003
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }
}