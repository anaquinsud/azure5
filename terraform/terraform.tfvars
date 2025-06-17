# ============================================================================
# GENERAL CONFIGURATION
# ============================================================================

project_name   = "cdp"
location_short = "sea"
environment         = "dev"
location           = "Southeast Asia"  # Singapore region
# resource_group_name = "rg-terraform-singapore-dev"
resource_group_name = ""

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

# ปิด NAT Gateway เพื่อประหยัดค่าใช้จ่าย (VM จะใช้ Public IP สำหรับ outbound)
enable_nat_gateway = false

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
# VIRTUAL MACHINE CONFIGURATION
# ============================================================================

vm_size            = "Standard_D2s_v3"
vm_disk_size       = 256
vm_admin_username  = "azureuser"

# SSH Public Key - Replace with your actual SSH public key
vm_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC37VjudioaJNAwKk7qHcGmiGLnh5+CdX07ZjhIP1xgcYyhDdhxKNS/L5nxD3NbP++YV8ZcFtLxl7k8QwAFNEZRBR4U0tpTheqCfILP/d1ZnNcSp6r+T3wtnDi5VuPfwNfUyNDYrP8IQDkr9jbHTk967Wsk7M15q+xa5lcQQGeTqdyRkLahkUSfixaQunJDRsxSQhyR7U5IvRNKF2pbH7Q65tWSqC/iSKOx8inRxa5mZKMEB7idplZ/xXoUl8B07byJeRgn5wpy6/JvaFj5TG+OC9EJKZigd8Y5zOif6q20vtxEGf0p2PPqa2XFXHuMaGC3/l13SgnQwEaQusVk5ZG2qs2pZpi66VkFeR7ZgdFdAF2IkJa7BcPwDdi/SmdCOZmYYfpcmHGgT9NBh5coOGCuzSB7k5di+vr/uQBOqjnxBxz5+005XjJrsu/WY0m0JCffoi1LduYmlcSm8X+Mes86rFvUtu4SaTwMTtQmoLmavxftBMjptAItMN3N/wO9RdNLKdLcsS3mnzdr6kngG3S5YVTn77hTNro6ImtGymfFRwdMkjljlTdbjUPZnN5mMsNJtYpzIw5lxARb6DXSUY1zWFRp+JKiEojVOSvob+Q39eGZX1SYS1W7rL9JppckqegrzI6rei459dqud8QzQMnCES0l83B/IPzHeltKy44mXw== emetworksprom2@EmetS-MacBook-Pro-M3.local"

# เปิด Public IP สำหรับ VM (จำเป็นสำหรับ VS Code Remote SSH และ outbound traffic เมื่อไม่มี NAT)
enable_vm_public_ip = true
# allowed_ssh_cidr   = "YOUR_IP_ADDRESS/32"  # Replace with your IP for security



# ============================================================================
# BASTION CONFIGURATION (เพิ่มในไฟล์ terraform.tfvars)
# ============================================================================

# เปิดใช้ Azure Bastion
enable_bastion = false

# ใช้ Basic SKU เพื่อประหยัดค่าใช้จ่าย (สำหรับ dev environment)
bastion_sku = "Standard"

# สำหรับ Basic SKU จะไม่สามารถตั้งค่า scale_units ได้
# bastion_scale_units = 2  # ใช้ได้เฉพาะ Standard SKU

# Features สำหรับ Basic SKU
bastion_copy_paste_enabled = true

# enable_bastion = true
# bastion_sku = "Standard"
# bastion_scale_units = 4
# enable_vm_public_ip = false  # เพื่อความปลอดภัย


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

# container_apps_external_enabled = true

# Container Apps Configuration
# container_apps_subnet_cidr = "10.0.4.0/23"  # /23 subnet สำหรับ Container Apps (required minimum)
container_apps_subnet_cidr = "10.0.8.0/21"