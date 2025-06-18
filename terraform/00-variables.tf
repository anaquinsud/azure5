# ============================================================================
# GENERAL VARIABLES
# ============================================================================

variable "environment" {
  description = "Environment name (e.g., dev, stg, prd)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "Southeast Asia"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "terraform-azure"
    ManagedBy   = "terraform"
  }
}

# ============================================================================
# NETWORK VARIABLES
# ============================================================================

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for outbound internet access from private subnets"
  type        = bool
  default     = false
}

# ============================================================================
# VMSS VARIABLES (แทนที่ VM variables)
# ============================================================================

variable "availability_zones" {
  description = "Availability zones for VMSS deployment"
  type        = list(string)
  default     = ["1", "2", "3"]
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones are required for HA."
  }
}

variable "vmss_instance_count" {
  description = "Initial number of VM instances (should match number of zones)"
  type        = number
  default     = 3
  validation {
    condition     = var.vmss_instance_count >= 2
    error_message = "Minimum 2 instances required for HA."
  }
}

variable "vmss_min_instances" {
  description = "Minimum instances (recommend 1 per zone)"
  type        = number
  default     = 3
}

variable "vmss_max_instances" {
  description = "Maximum instances for cost control"
  type        = number
  default     = 9
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for VMSS"
  type        = bool
  default     = true
}

variable "enable_scheduled_scaling" {
  description = "Enable time-based scaling for cost optimization"
  type        = bool
  default     = true
}

variable "enable_vmss_ssh_access" {
  description = "Enable SSH access to VMSS instances through NAT pool"
  type        = bool
  default     = true
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "vm_disk_size" {
  description = "Size of the VM OS disk in GB"
  type        = number
  default     = 128
}

variable "vm_admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

variable "vm_ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

variable "storage_type" {
  description = "Storage account type for cost optimization"
  type        = string
  default     = "Standard_LRS"
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.storage_type)
    error_message = "Storage type must be Standard_LRS, StandardSSD_LRS, or Premium_LRS."
  }
}

variable "cloud_init_script" {
  description = "Cloud-init script for VMSS instances"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "The allowed_ssh_cidr must be a valid CIDR block."
  }
}

# ============================================================================
# CONTAINER APPS VARIABLES
# ============================================================================

variable "nodejs_api_fqdn" {
  description = "FQDN of the Node.js API Container App (if using external container apps)"
  type        = string
  default     = "nodejs-api.example.com"
}

variable "golang_api_fqdn" {
  description = "FQDN of the Golang API Container App (if using external container apps)"
  type        = string
  default     = "golang-api.example.com"
}

# ============================================================================
# BASTION VARIABLES
# ============================================================================

variable "enable_bastion" {
  description = "Enable Azure Bastion for secure VM access"
  type        = bool
  default     = false
}

variable "bastion_sku" {
  description = "Azure Bastion SKU (Basic or Standard)"
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Standard"], var.bastion_sku)
    error_message = "Bastion SKU must be either 'Basic' or 'Standard'."
  }
}

variable "bastion_scale_units" {
  description = "Number of scale units for Azure Bastion (2-50, only applies to Standard SKU)"
  type        = number
  default     = 2
  validation {
    condition     = var.bastion_scale_units >= 2 && var.bastion_scale_units <= 50
    error_message = "Bastion scale units must be between 2 and 50."
  }
}

variable "bastion_file_copy_enabled" {
  description = "Enable file copy feature for Bastion (Standard SKU only)"
  type        = bool
  default     = true
}

variable "bastion_copy_paste_enabled" {
  description = "Enable copy/paste feature for Bastion"
  type        = bool
  default     = true
}

variable "bastion_ip_connect_enabled" {
  description = "Enable IP connect feature for Bastion (Standard SKU only)"
  type        = bool
  default     = true
}

variable "bastion_shareable_link_enabled" {
  description = "Enable shareable link feature for Bastion (Standard SKU only)"
  type        = bool
  default     = false
}

variable "bastion_tunneling_enabled" {
  description = "Enable tunneling feature for Bastion (Standard SKU only)"
  type        = bool
  default     = true
}

# ============================================================================
# STATIC WEB APPS VARIABLES
# ============================================================================

variable "static_web_app_location" {
  description = "Azure region for Static Web Apps (limited regions available)"
  type        = string
  default     = "East Asia"
  validation {
    condition     = contains(["West US 2", "Central US", "East US 2", "West Europe", "East Asia"], var.static_web_app_location)
    error_message = "Static Web App location must be one of: West US 2, Central US, East US 2, West Europe, East Asia."
  }
}

variable "static_web_app_sku_tier" {
  description = "SKU tier for Static Web App"
  type        = string
  default     = "Free"
  validation {
    condition     = contains(["Free", "Standard"], var.static_web_app_sku_tier)
    error_message = "Static Web App SKU tier must be either 'Free' or 'Standard'."
  }
}

variable "static_web_app_sku_size" {
  description = "SKU size for Static Web App"
  type        = string
  default     = "Free"
  validation {
    condition     = contains(["Free", "Standard"], var.static_web_app_sku_size)
    error_message = "Static Web App SKU size must be either 'Free' or 'Standard'."
  }
}

variable "static_web_app_custom_domain" {
  description = "Custom domain for Static Web App"
  type        = string
  default     = "web-cdp.ts-lucky.space"
}

variable "enable_static_web_functions" {
  description = "Enable Function App integration with Static Web App"
  type        = bool
  default     = false
}

variable "function_app_id" {
  description = "ID of the Function App to integrate with Static Web App (if enabled)"
  type        = string
  default     = ""
}

variable "enable_custom_domain" {
  description = "Enable custom domain for Static Web App (requires DNS CNAME record to be created first)"
  type        = bool
  default     = false
}

# เพิ่มใน variables.tf
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "cdp"
}

variable "location_short" {
  description = "Short name for Azure region (used in naming)"
  type        = string
  default     = "sea"  # Southeast Asia
}

# ============================================================================
# CONTAINER APPS VARIABLES
# ============================================================================

variable "container_apps_subnet_cidr" {
  description = "CIDR block for Container Apps subnet (must be /23 or larger for Container Apps Environment)"
  type        = string
  default     = "10.0.8.0/21"
  validation {
    condition     = can(cidrhost(var.container_apps_subnet_cidr, 0))
    error_message = "The container_apps_subnet_cidr must be a valid CIDR block."
  }
}

variable "vm_subnet_cidr" {
  description = "CIDR block for VM subnet (used for NSG rules)"
  type        = string
  default     = "10.0.1.0/24"
  validation {
    condition     = can(cidrhost(var.vm_subnet_cidr, 0))
    error_message = "The vm_subnet_cidr must be a valid CIDR block."
  }
}

variable "enable_zone_redundancy" {
  description = "Enable zone redundancy for Container Apps Environment"
  type        = bool
  default     = true
  validation {
    condition     = can(tobool(var.enable_zone_redundancy))
    error_message = "Zone redundancy must be a boolean value."
  }
}