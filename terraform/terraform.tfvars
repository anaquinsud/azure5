# ============================================================================
# GENERAL CONFIGURATION
# ============================================================================

project_name        = "samsung"
location_short      = "sea"
environment         = "dev"
location           = "Southeast Asia"  # Singapore region
resource_group_name = ""  # Auto-generated if empty

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

# Enable NAT Gateway for outbound internet access from private subnets
enable_nat_gateway = true

# Container Apps subnet CIDR (must be /21 or larger)
container_apps_subnet_cidr = "10.0.8.0/21"

# ============================================================================
# TAGS CONFIGURATION
# ============================================================================

common_tags = {
  Environment = "dev"
  Project     = "terraform-azure-singapore"
  ManagedBy   = "terraform"
  Region      = "Southeast Asia"
  Owner       = "DevOps Team"
}

# ============================================================================
# VIRTUAL MACHINE CONFIGURATION (LOOP-BASED)
# ============================================================================

# Number of VMs to create
vm_count = 1

# Availability zones for VM deployment
availability_zones = ["1"]

# VM specifications
vm_size            = "Standard_D2s_v3"
vm_disk_size       = 64
vm_admin_username  = "azureuser"

# SSH Public Key - Replace with your actual SSH public key
vm_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSZs6t3CddFPgQ8FA20lSNI8fjZ8vaDDHxccRHJLjptK0f7Prdj3moiYcNpHG05CZeWP35/2h98rjkAmZ7bAHPYZJ32vXNNefiNJZ7unUDyH8NJ0x7TCIhFUCx9pCnuTPmWweEuSFmNU8PQrCoSyjL7DIJCQVE/sHTbYJ8MwHyoR5nMjZQms1Z2c+TjxLcm03noJsz+7wQzZu6iWip9DSTieY+10QVORHLmT87+9A0BsMhwaoDNVE7UdEb8IWewoffWCDY7JTbJLnMsbrGmrqQlbPP8fdM3pwUcmQUevjrwur8afoWTEfuQ6na2iqvM9M0m7r03dcgJWTaWFJiRpBv9fYDzTevCmRnN/mbReH8wqwO7dTcwuD//jOjHizqRF0hkoSkxZ/T5ZkN2mW4yY8g9Hqc8QnUqejgI1l+GXKr+DLM9WxYe6z+y1wsZZ5KeFfaGWPqHGVFqBYuoKFSrgt84eI072V8BG7Y52Blo/S2AUt/mHscRbpuM7HRrKyysm0zBypeFdqD/7BoSfVjrBjz+zWv4i9WLaQ9aWXy9PGT3Rlv9FzSnwA+r6c/V2eferveCjrs5AyCH5P3XhEkDir+5iDSJ+dyBlqGUth+Yk6icH4aIUqsZJsJYyM4SwBtanq2STBfbnb23QJLz4ExmfUoVAUgdDOpzep0VpJj8RBzqQ== admin@emetworks.com"

# Disable Public IP for VMs (use Bastion for secure access)
enable_vm_public_ip = true

# CIDR block allowed for SSH access (only used when enable_vm_public_ip is true)
allowed_ssh_cidr = "0.0.0.0/0"  # Replace with your IP for security

# ============================================================================
# BASTION CONFIGURATION
# ============================================================================

# Enable Azure Bastion for secure VM access
enable_bastion = false

# Bastion SKU (Basic or Standard)
bastion_sku = "Standard"

# Bastion scale units (only for Standard SKU)
bastion_scale_units = 2

# Bastion features
bastion_copy_paste_enabled      = true
bastion_file_copy_enabled       = true
bastion_ip_connect_enabled      = true
bastion_shareable_link_enabled  = false
bastion_tunneling_enabled       = true

# ============================================================================
# STATIC WEB APP CONFIGURATION
# ============================================================================

# Static Web App Configuration
static_web_app_sku_tier       = "Free"  # Use "Standard" for production
static_web_app_sku_size       = "Free"  # Use "Standard" for production
static_web_app_custom_domain  = "web-cdp.ts-lucky.space"
static_web_app_location       = "East Asia"  # Closest supported region to Singapore

# Function App Integration (optional)
enable_static_web_functions   = false
# function_app_id             = ""  # Add Function App ID if needed

# Custom Domain Configuration (set to false initially, enable after DNS setup)
enable_custom_domain          = false

# ============================================================================
# CONTAINER APPS CONFIGURATION
# ============================================================================

# Enable zone redundancy for Container Apps Environment
enable_zone_redundancy = true

# Container Apps API FQDNs (for external reference)
nodejs_api_fqdn = "nodejs-api.example.com"
golang_api_fqdn = "golang-api.example.com"