# ============================================================================
# GENERAL VARIABLES
# ============================================================================

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
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
# VIRTUAL MACHINE VARIABLES
# ============================================================================

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_disk_size" {
  description = "Size of the VM OS disk in GB"
  type        = number
  default     = 256
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

variable "enable_vm_public_ip" {
  description = "Enable public IP for VM (required for VS Code Remote SSH)"
  type        = bool
  default     = true
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
# BASTION VARIABLES (เพิ่มในไฟล์ variables.tf)
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
# CONTAINER APPS VARIABLES (เพิ่ม)
# ============================================================================

variable "container_apps_external_enabled" {
  description = "Enable external access to Container Apps (set to false for internal-only access)"
  type        = bool
  default     = false
}

variable "container_apps_subnet_cidr" {
  description = "CIDR block for Container Apps subnet (must be /23 or larger)"
  type        = string
  default     = "10.0.2.0/23"
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


# ============================================================================
# STATIC WEB APPS VARIABLES (Add to variables.tf)
# ============================================================================

variable "static_web_app_location" {
  description = "Azure region for Static Web Apps (limited regions available)"
  type        = string
  default     = "East Asia"  # Closest to Singapore that supports Static Web Apps
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