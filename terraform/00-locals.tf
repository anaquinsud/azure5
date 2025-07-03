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
  
  # Network Resources - Updated for multi-zone
  vnet_name                      = "${local.base_name}-vnet"
  subnet_private_name_prefix     = "${local.base_name}-snet-private"
  subnet_bastion_name            = "${local.base_name}-snet-bastion"
  subnet_nat_name                = "${local.base_name}-snet-nat"
  subnet_container_apps_name     = "${local.base_name}-snet-container-apps"
  nsg_name                       = "${local.base_name}-nsg"
  nsg_bastion_name              = "${local.base_name}-nsg-bastion"
  
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
  
  # Create subnet CIDR blocks for each zone
  private_subnet_cidrs = {
    "1" = "10.0.1.0/24"
    "2" = "10.0.2.0/24"
  }
  
  # ============================================================================
  # VIRTUAL MACHINES CONFIGURATION (LOOP-BASED)
  # ============================================================================
  
  virtual_machines = {
    for i in range(var.vm_count) : "vm-${i + 1}" => {
      name           = "${local.base_name}-vm-nginx-${i + 1}"
      nic_name       = "${local.base_name}-nic-vm-${i + 1}"
      pip_name       = "${local.base_name}-pip-vm-${i + 1}"
      zone           = var.availability_zones[i % length(var.availability_zones)]
      subnet_key     = var.availability_zones[i % length(var.availability_zones)]
      size           = var.vm_size
      disk_size      = var.vm_disk_size
      admin_username = var.vm_admin_username
      ssh_public_key = var.vm_ssh_public_key
      
      # VM-specific tags
      tags = {
        VMName = "${local.base_name}-vm-nginx-${i + 1}"
        Zone   = var.availability_zones[i % length(var.availability_zones)]
        Index  = i + 1
      }
    }
  }
  
  # ============================================================================
  # SERVICE BUS QUEUES CONFIGURATION
  # ============================================================================
  
  servicebus_queues = {
    "samsung-cdp-gateway-message" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "P14D"  # 14 days
      lock_duration           = "PT30S" # 30 seconds
    }
    "samsung-cdp-gateway-message-athena" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-cdp-gateway-message-upload" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "P14D"  # 14 days
      lock_duration           = "PT30S" # 30 seconds
    }
    "samsung-cdp-gateway-multicast" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-cdp-gateway-richmenu" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "P14D"  # 14 days
      lock_duration           = "PT30S" # 30 seconds
    }
    "samsung-cdp-link-tracking" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-cdp-new-link-tracking" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "P14D"  # 14 days
      lock_duration           = "PT30S" # 30 seconds
    }
    "samsung-cdp-richmenu-tracking" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-cdp-send-smart-broadcast" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-cdp-smart-broadcast-impresstions" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "P14D"  # 14 days
      lock_duration           = "PT30S" # 30 seconds
    }
    "samsung-cdp-survey-tracking" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-cdp-tag-tracking" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "P14D"  # 14 days
      lock_duration           = "PT30S" # 30 seconds
    }
    "samsung-cdp-unidentify-link" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-create-audit-log" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "P14D"  # 14 days
      lock_duration           = "PT30S" # 30 seconds
    }
    "samsung-create-audit-log-detail" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-create-customer-child-link-tracking" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-create-customer-child-note" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-create-customer-child-profile" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-create-customer-child-survey" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-create-customer-child-tag" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-create-customer-log" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-delete-customer-child-note" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-delete-customer-child-tag" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-download" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    "samsung-tracking-segment-customer-child" = {
      enable_partitioning      = false
      max_size_in_megabytes   = 1024
      default_message_ttl     = "PT5M"  # 5 minutes for OTP
      lock_duration           = "PT30S"
    }
    # "cdp-queue-survey-tracking" = {
    #   enable_partitioning      = false
    #   max_size_in_megabytes   = 1024
    #   default_message_ttl     = "P14D"  # 14 days
    #   lock_duration           = "PT30S" # 30 seconds
    # }
    # "crm-otp-queue" = {
    #   enable_partitioning      = false
    #   max_size_in_megabytes   = 1024
    #   default_message_ttl     = "PT5M"  # 5 minutes for OTP
    #   lock_duration           = "PT30S"
    # }
  }
  
  # ============================================================================
  # CONTAINER APPS CONFIGURATION
  # ============================================================================
  
  business_hours_config = {
    timezone            = "Asia/Bangkok"
    start_time         = "0 8 * * MON-FRI"    # 8:00 AM Monday-Friday
    end_time           = "0 20 * * MON-FRI"   # 8:00 PM Monday-Friday
    business_replicas  = "1"                  # จำนวน containers ในเวลาทำการ
    after_hours_replicas = "0"               # จำนวน containers หลังเลิกงาน
  }

  weekend_config = {
    timezone           = "Asia/Bangkok"
    start_time        = "0 0 * * SAT"        # Saturday 00:00
    end_time          = "0 0 * * MON"        # Monday 00:00
    weekend_replicas  = "0"                  # ปิดสุดสัปดาห์
  }

  standard_scale_rules = [
    {
      name = "business-hours-scale"
      type = "cron"
      metadata = {
        timezone        = local.business_hours_config.timezone
        start          = local.business_hours_config.start_time
        end            = local.business_hours_config.end_time
        desiredReplicas = local.business_hours_config.business_replicas
      }
    },
    {
      name = "after-hours-scale"
      type = "cron"
      metadata = {
        timezone        = local.business_hours_config.timezone
        start          = local.business_hours_config.end_time
        end            = local.business_hours_config.start_time
        desiredReplicas = local.business_hours_config.after_hours_replicas
      }
    },
    {
      name = "weekend-scale"
      type = "cron"
      metadata = {
        timezone        = local.weekend_config.timezone
        start          = local.weekend_config.start_time
        end            = local.weekend_config.end_time
        desiredReplicas = local.weekend_config.weekend_replicas
      }
    }
  ]

  container_apps = {
    # CDP
    "${local.project}-cosumer-customer-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 80
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-broadcast-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 80
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-cdp-api-${local.environment}" = {
      image        = "nginx:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "nodejs"
      }
    }
    "${local.project}-cdp-segment-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 80
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-download-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 80
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-cron-function-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 80
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-richmenu-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 80
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-link-tracking-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 80
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-project-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 80
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-cdp-member-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 80
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-customer-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 80
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-auth-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 8000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "8000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-cronjob-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 80
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-pdpa-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 80
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "80"
        "API_TYPE"    = "golang"
      }
    }
    # Chat canter
    "${local.project}-chat-message-worker-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-shopee-shop-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-lazada-shop-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-tiktok-shop-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-tiktok-cronjob-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-tiktok-chat-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-youtube-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-youtube-cronjob-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-chat-cron-func-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-chat-cronjob-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-chat-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-chat-upload-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    "${local.project}-chat-webhook-api-${local.environment}" = {
      image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 0
      max_replicas = 1
      target_port  = 3000
      scale_rules = local.standard_scale_rules
      env_vars = {
        "ENVIRONMENT" = var.environment
        "PORT"        = "3000"
        "API_TYPE"    = "golang"
      }
    }
    # "golang-api" = {
    #   image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    #   cpu          = 0.5
    #   memory       = "1Gi"
    #   min_replicas = 3
    #   max_replicas = 9
    #   target_port  = 80
    #   env_vars = {
    #     "ENVIRONMENT" = var.environment
    #     "PORT"        = "80"
    #     "API_TYPE"    = "golang"
    #   }
    # }
    # "nodejs-api" = {
    #   image        = "nginx:latest"
    #   cpu          = 0.5
    #   memory       = "1Gi"
    #   min_replicas = 3
    #   max_replicas = 9
    #   target_port  = 80
    #   env_vars = {
    #     "ENVIRONMENT" = var.environment
    #     "PORT"        = "80"
    #     "API_TYPE"    = "nodejs"
    #   }
    # }
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
    "Allow-ClickHouse-HTTP" = {
      priority                   = 1006
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8123"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    "Allow-ClickHouse-Native" = {
      priority                   = 1007
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "9000"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
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