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

variable "resource_group_name" {
  description = "Name of the resource group (auto-generated if empty)"
  type        = string
  default     = ""
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
  default     = true
}

variable "container_apps_subnet_cidr" {
  description = "CIDR block for Container Apps subnet (must be /21 or larger for Container Apps Environment)"
  type        = string
  default     = "10.0.8.0/21"
  validation {
    condition     = can(cidrhost(var.container_apps_subnet_cidr, 0))
    error_message = "The container_apps_subnet_cidr must be a valid CIDR block."
  }
}

variable "enable_zone_redundancy" {
  description = "Enable zone redundancy for Container Apps Environment"
  type        = bool
  default     = true
}

# ============================================================================
# VIRTUAL MACHINE VARIABLES (UPDATED FOR LOOP-BASED)
# ============================================================================

variable "vm_count" {
  description = "Number of VMs to create across zones"
  type        = number
  default     = 2
  validation {
    condition     = var.vm_count > 0 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10."
  }
}

variable "availability_zones" {
  description = "List of availability zones to deploy VMs (VMs will cycle through these zones)"
  type        = list(string)
  default     = ["1", "2"]
  validation {
    condition = length(var.availability_zones) > 0 && length(var.availability_zones) <= 3
    error_message = "Availability zones must contain 1-3 zones."
  }
}

variable "vm_size" {
  description = "Size of the virtual machines"
  type        = string
  default     = "Standard_D2s_v3"
  validation {
    condition = contains([
      "Standard_B2s", "Standard_B2ms", "Standard_B4ms",
      "Standard_D2s_v3", "Standard_D4s_v3", "Standard_D8s_v3",
      "Standard_E2s_v3", "Standard_E4s_v3", "Standard_E8s_v3"
    ], var.vm_size)
    error_message = "VM size must be a valid Azure VM size."
  }
}

variable "vm_disk_size" {
  description = "Size of the VM OS disk in GB"
  type        = number
  default     = 256
  validation {
    condition     = var.vm_disk_size >= 64 && var.vm_disk_size <= 2048
    error_message = "VM disk size must be between 64 and 2048 GB."
  }
}

variable "vm_admin_username" {
  description = "Admin username for the virtual machines"
  type        = string
  default     = "azureuser"
  validation {
    condition     = length(var.vm_admin_username) >= 3 && length(var.vm_admin_username) <= 32
    error_message = "Admin username must be between 3 and 32 characters."
  }
}

variable "vm_ssh_public_key" {
  description = "SSH public key for VM access (must be a valid SSH public key)"
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("^ssh-(rsa|ed25519)", var.vm_ssh_public_key))
    error_message = "SSH public key must be a valid SSH public key starting with 'ssh-rsa' or 'ssh-ed25519'."
  }
}

variable "enable_vm_public_ip" {
  description = "Enable public IP for VMs (set to false for production, use Bastion instead)"
  type        = bool
  default     = false
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access (only used when enable_vm_public_ip is true)"
  type        = string
  default     = "0.0.0.0/0"
  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "The allowed_ssh_cidr must be a valid CIDR block."
  }
}

# ============================================================================
# BASTION VARIABLES
# ============================================================================

variable "enable_bastion" {
  description = "Enable Azure Bastion for secure VM access (recommended for production)"
  type        = bool
  default     = true
}

variable "bastion_sku" {
  description = "Azure Bastion SKU (Basic or Standard)"
  type        = string
  default     = "Standard"
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
# ADVANCED CONFIGURATION VARIABLES
# ============================================================================

variable "vm_custom_configurations" {
  description = "Custom VM configurations (advanced users only)"
  type = map(object({
    size           = optional(string, "Standard_D2s_v3")
    disk_size      = optional(number, 256)
    zone           = optional(string, "1")
    subnet_key     = optional(string, "1")
    enable_public_ip = optional(bool, false)
  }))
  default = {}
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking for VMs (requires supported VM sizes)"
  type        = bool
  default     = false
}

variable "vm_storage_account_type" {
  description = "Storage account type for VM OS disks"
  type        = string
  default     = "Premium_LRS"
  validation {
    condition     = contains(["Standard_LRS", "Premium_LRS", "StandardSSD_LRS"], var.vm_storage_account_type)
    error_message = "Storage account type must be Standard_LRS, Premium_LRS, or StandardSSD_LRS."
  }
}