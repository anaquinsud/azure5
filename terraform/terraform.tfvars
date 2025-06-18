# ============================================================================
# GENERAL CONFIGURATION
# ============================================================================

project_name   = "cdp"
location_short = "sea"
environment         = "dev"  # เปลี่ยนเป็น "prd" สำหรับ production
location           = "Southeast Asia"  # Singapore region
resource_group_name = ""

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

# ปิด NAT Gateway เพื่อประหยัดค่าใช้จ่าย (VMSS จะใช้ Load Balancer สำหรับ outbound)
enable_nat_gateway = false

# ============================================================================
# TAGS CONFIGURATION
# ============================================================================

common_tags = {
  Environment = "dev"          # เปลี่ยนเป็น "prd" สำหรับ production
  Project     = "terraform-azure-singapore"
  ManagedBy   = "terraform"
  Region      = "Southeast Asia"
  Owner       = "DevOps Team"
}

# ============================================================================
# VMSS CONFIGURATION (แทนที่ VM Configuration)
# ============================================================================

# Zone Configuration สำหรับ High Availability
availability_zones = ["1", "2"]  # 2 zones ใน Southeast Asia

# Instance Configuration (Cost-Optimized)
vmss_instance_count     = 2   # 1 per zone (dev: 2, prd: 3)
vmss_min_instances      = 2   # ไม่ลดต่ำกว่านี้ (dev: 2, prd: 3)
vmss_max_instances      = 4   # สูงสุด 2 per zone เพื่อประหยัด (dev: 4, prd: 15)

# VM Size - เลือก cost-effective
vm_size = "Standard_B2s"      # 💰 Burstable instances ประหยัดที่สุด (dev)
# vm_size = "Standard_D2s_v3" # Production: ใช้ standard ถ้าต้องการ performance

vm_disk_size = 128            # 💰 ลดขนาด disk (dev: 128GB, prd: 256GB)
storage_type = "Standard_LRS" # 💰 ใช้ storage ถูกที่สุด (dev: Standard_LRS, prd: Premium_LRS)

vm_admin_username  = "azureuser"

# SSH Public Key - Replace with your actual SSH public key
vm_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC37VjudioaJNAwKk7qHcGmiGLnh5+CdX07ZjhIP1xgcYyhDdhxKNS/L5nxD3NbP++YV8ZcFtLxl7k8QwAFNEZRBR4U0tpTheqCfILP/d1ZnNcSp6r+T3wtnDi5VuPfwNfUyNDYrP8IQDkr9jbHTk967Wsk7M15q+xa5lcQQGeTqdyRkLahkUSfixaQunJDRsxSQhyR7U5IvRNKF2pbH7Q65tWSqC/iSKOx8inRxa5mZKMEB7idplZ/xXoUl8B07byJeRgn5wpy6/JvaFj5TG+OC9EJKZigd8Y5zOif6q20vtxEGf0p2PPqa2XFXHuMaGC3/l13SgnQwEaQusVk5ZG2qs2pZpi66VkFeR7ZgdFdAF2IkJa7BcPwDdi/SmdCOZmYYfpcmHGgT9NBh5coOGCuzSB7k5di+vr/uQBOqjnxBxz5+005XjJrsu/WY0m0JCffoi1LduYmlcSm8X+Mes86rFvUtu4SaTwMTtQmoLmavxftBMjptAItMN3N/wO9RdNLKdLcsS3mnzdr6kngG3S5YVTn77hTNro6ImtGymfFRwdMkjljlTdbjUPZnN5mMsNJtYpzIw5lxARb6DXSUY1zWFRp+JKiEojVOSvob+Q39eGZX1SYS1W7rL9JppckqegrzI6rei459dqud8QzQMnCES0l83B/IPzHeltKy44mXw== emetworksprom2@EmetS-MacBook-Pro-M3.local"

# Auto-scaling Configuration
enable_autoscaling         = true
enable_scheduled_scaling   = true   # dev: true, prd: false (ใช้ manual scaling)

# SSH Access
enable_vmss_ssh_access = true       # dev: true, prd: false (ใช้ Bastion แทน)
allowed_ssh_cidr       = "0.0.0.0/0"  # ควรจำกัดเป็น IP ของคุณสำหรับความปลอดภัย

# Cloud-init script (nginx เดี๋ยวไป remote install เอง)
cloud_init_script = <<-EOF
#cloud-config
package_update: true
package_upgrade: true
packages:
  - curl
  - htop
  - git

runcmd:
  - echo "<h1>VMSS Instance $(hostname) - Zone $(curl -s http://169.254.169.254/metadata/instance/compute/zone?api-version=2021-02-01 -H 'Metadata:true')</h1>" > /var/www/html/index.html
EOF

# ============================================================================
# BASTION CONFIGURATION
# ============================================================================

# เปิดใช้ Azure Bastion (สำหรับ production หรือความปลอดภัย)
enable_bastion = false  # dev: false, prd: true

# Bastion Configuration (ใช้เมื่อ enable_bastion = true)
# bastion_sku = "Standard"
# bastion_scale_units = 4
# bastion_copy_paste_enabled = true
# bastion_file_copy_enabled = true
# bastion_tunneling_enabled = true

# ============================================================================
# STATIC WEB APP CONFIGURATION
# ============================================================================

# Static Web App Configuration
static_web_app_sku_tier       = "Free"  # dev: Free, prd: Standard
static_web_app_sku_size       = "Free"  # dev: Free, prd: Standard
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

# Container Apps Configuration
container_apps_subnet_cidr = "10.0.8.0/21"  # /21 subnet สำหรับ Container Apps

# ============================================================================
# PRODUCTION CONFIGURATION (COMMENT/UNCOMMENT เมื่อสลับ Environment)
# ============================================================================

# 🚨 สำหรับ PRODUCTION - Uncomment บรรทัดด้านล่างและ comment dev config ด้านบน

# environment = "prd"

# common_tags = {
#   Environment = "prd"
#   Project     = "terraform-azure-singapore"
#   ManagedBy   = "terraform"
#   Region      = "Southeast Asia"
#   Owner       = "DevOps Team"
#   CostCenter  = "IT-Infrastructure"
# }

# # Production VMSS Configuration
# vmss_instance_count     = 6   # 2 per zone สำหรับ production
# vmss_min_instances      = 6   # ไม่ลดต่ำกว่านี้
# vmss_max_instances      = 15  # 5 per zone สำหรับ peak load

# # Production VM Configuration
# vm_size = "Standard_D2s_v3"     # Performance ดีกว่าสำหรับ production
# vm_disk_size = 256              # Disk ใหญ่ขึ้น
# storage_type = "Premium_LRS"    # Performance ดีที่สุด

# # Production Security
# enable_vmss_ssh_access = false # ปิด SSH access
# enable_bastion = true           # ใช้ Bastion แทน
# bastion_sku = "Standard"
# bastion_scale_units = 4

# # Production Scaling
# enable_scheduled_scaling = false # ใช้ manual scaling

# # Production Static Web App
# static_web_app_sku_tier = "Standard"
# static_web_app_sku_size = "Standard"
# enable_custom_domain = true     # เปิดใช้ custom domain

# # Production Network Security
# allowed_ssh_cidr = "YOUR_OFFICE_IP/32"  # จำกัด IP สำหรับ SSH