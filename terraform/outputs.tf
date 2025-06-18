# ============================================================================
# RESOURCE GROUP OUTPUTS
# ============================================================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# ============================================================================
# NETWORK OUTPUTS
# ============================================================================

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.private.id
}

output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT gateway (if enabled)"
  value       = var.enable_nat_gateway ? azurerm_public_ip.nat[0].ip_address : null
}

output "nat_gateway_enabled" {
  description = "Whether NAT Gateway is enabled"
  value       = var.enable_nat_gateway
}

# ============================================================================
# VMSS OUTPUTS (แทนที่ VM outputs)
# ============================================================================

output "vmss_id" {
  description = "ID of the virtual machine scale set"
  value       = azurerm_linux_virtual_machine_scale_set.main.id
}

output "vmss_name" {
  description = "Name of the virtual machine scale set"
  value       = azurerm_linux_virtual_machine_scale_set.main.name
}

output "vmss_instance_count" {
  description = "Current number of instances in the scale set"
  value       = azurerm_linux_virtual_machine_scale_set.main.instances
}

output "vmss_zones" {
  description = "Availability zones for the VMSS"
  value       = azurerm_linux_virtual_machine_scale_set.main.zones
}

output "autoscaling_enabled" {
  description = "Whether autoscaling is enabled"
  value       = var.enable_autoscaling
}

# ============================================================================
# LOAD BALANCER OUTPUTS (Updated)
# ============================================================================

output "load_balancer_id" {
  description = "ID of the load balancer"
  value       = azurerm_lb.main.id
}

output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer (main access point)"
  value       = azurerm_public_ip.lb.ip_address
}

output "load_balancer_frontend_ip" {
  description = "Frontend IP configuration of the load balancer"
  value       = azurerm_lb.main.frontend_ip_configuration[0].private_ip_address
}

# ============================================================================
# SSH ACCESS OUTPUTS
# ============================================================================

output "vmss_ssh_instructions" {
  description = "SSH connection instructions for VMSS instances"
  value = var.enable_vmss_ssh_access ? {
    load_balancer_ip = azurerm_public_ip.lb.ip_address
    ssh_command_template = "ssh -p 5000X ${var.vm_admin_username}@${azurerm_public_ip.lb.ip_address}"
    port_mapping = "Instance 0: port 50000, Instance 1: port 50001, etc."
    note = "Replace X in 5000X with instance number (0,1,2...)"
    examples = [
      "ssh -p 50000 ${var.vm_admin_username}@${azurerm_public_ip.lb.ip_address}  # Instance 0",
      "ssh -p 50001 ${var.vm_admin_username}@${azurerm_public_ip.lb.ip_address}  # Instance 1",
      "ssh -p 50002 ${var.vm_admin_username}@${azurerm_public_ip.lb.ip_address}  # Instance 2"
    ]
  } : {
    load_balancer_ip = azurerm_public_ip.lb.ip_address
    ssh_command_template = "SSH access disabled"
    port_mapping = "SSH access disabled"
    note = "SSH access disabled. Enable by setting enable_vmss_ssh_access = true"
    examples = ["SSH access is disabled"]
  }
}

output "vmss_ssh_connections" {
  description = "SSH commands for each active instance"
  value = var.enable_vmss_ssh_access ? [
    for i in range(var.vmss_instance_count) : {
      instance = i
      port = 50000 + i
      command = "ssh -p ${50000 + i} ${var.vm_admin_username}@${azurerm_public_ip.lb.ip_address}"
    }
  ] : []
}

# Alternative: Separate outputs (simpler approach)
output "load_balancer_ip" {
  description = "Load Balancer Public IP"
  value       = azurerm_public_ip.lb.ip_address
}

output "ssh_enabled" {
  description = "Whether SSH access is enabled"
  value       = var.enable_vmss_ssh_access
}

output "ssh_examples" {
  description = "SSH command examples (when enabled)"
  value = var.enable_vmss_ssh_access ? [
    "ssh -p 50000 ${var.vm_admin_username}@${azurerm_public_ip.lb.ip_address}  # Instance 0",
    "ssh -p 50001 ${var.vm_admin_username}@${azurerm_public_ip.lb.ip_address}  # Instance 1", 
  ] : ["SSH access disabled - enable with enable_vmss_ssh_access = true"]
}

# ============================================================================
# CONTAINER APPS OUTPUTS (UPDATED FOR LOOPS)
# ============================================================================

output "container_app_environment_id" {
  description = "ID of the Container Apps environment"
  value       = azurerm_container_app_environment.main.id
}

# Individual app outputs for backward compatibility
output "golang_api_fqdn" {
  description = "FQDN of the Golang API Container App"
  value       = azurerm_container_app.apps["golang-api"].latest_revision_fqdn
}

output "nodejs_api_fqdn" {
  description = "FQDN of the Node.js API Container App"
  value       = azurerm_container_app.apps["nodejs-api"].latest_revision_fqdn
}

# All container apps output (new)
output "container_apps" {
  description = "All Container Apps information"
  value = {
    for name, app in azurerm_container_app.apps : 
    name => {
      id   = app.id
      name = app.name
      fqdn = app.latest_revision_fqdn
      url  = "https://${app.latest_revision_fqdn}"
      note = "Private access only - accessible from VMSS instances"
    }
  }
}

# ============================================================================
# STORAGE OUTPUTS (UPDATED FOR LOOPS)
# ============================================================================

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

# Main container for backward compatibility
output "storage_container_name" {
  description = "Name of the main storage container"
  value       = azurerm_storage_container.containers["main"].name
}

# All storage containers output (new)
output "storage_containers" {
  description = "All storage containers information"
  value = {
    for name, container in azurerm_storage_container.containers : 
    name => {
      id   = container.id
      name = container.name
    }
  }
}

# ============================================================================
# SERVICE BUS OUTPUTS (UPDATED FOR LOOPS)
# ============================================================================

output "servicebus_namespace_name" {
  description = "Name of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.name
}

output "servicebus_connection_string" {
  description = "Primary connection string for the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.default_primary_connection_string
  sensitive   = true
}

# Individual queues for backward compatibility
output "cdp_queue_survey_tracking_name" {
  description = "Name of the CDP queue survey tracking"
  value       = azurerm_servicebus_queue.queues["cdp-queue-survey-tracking"].name
}

output "crm_otp_queue_name" {
  description = "Name of the CRM OTP queue"
  value       = azurerm_servicebus_queue.queues["crm-otp-queue"].name
}

# All queues output (new)
output "servicebus_queues" {
  description = "All Service Bus queues information"
  value = {
    for name, queue in azurerm_servicebus_queue.queues : 
    name => {
      id   = queue.id
      name = queue.name
    }
  }
}

# ============================================================================
# CONTAINER REGISTRY OUTPUTS
# ============================================================================

output "container_registry_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.main.name
}

output "container_registry_login_server" {
  description = "Login server of the Azure Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "container_registry_admin_username" {
  description = "Admin username for the Azure Container Registry"
  value       = azurerm_container_registry.main.admin_username
}

output "container_registry_admin_password" {
  description = "Admin password for the Azure Container Registry"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

# ============================================================================
# STATIC WEB APPS OUTPUTS
# ============================================================================

output "static_web_app_id" {
  description = "ID of the Static Web App"
  value       = azurerm_static_web_app.web_cdp.id
}

output "static_web_app_name" {
  description = "Name of the Static Web App"
  value       = azurerm_static_web_app.web_cdp.name
}

output "static_web_app_location" {
  description = "Location of the Static Web App"
  value       = azurerm_static_web_app.web_cdp.location
}

output "static_web_app_default_host_name" {
  description = "Default hostname of the Static Web App"
  value       = azurerm_static_web_app.web_cdp.default_host_name
}

output "static_web_app_api_key" {
  description = "API key for the Static Web App deployment"
  value       = azurerm_static_web_app.web_cdp.api_key
  sensitive   = true
}

output "static_web_app_custom_domain" {
  description = "Custom domain configured for the Static Web App (if enabled)"
  value       = var.enable_custom_domain ? var.static_web_app_custom_domain : "Not configured"
}

output "static_web_container_name" {
  description = "Name of the static web storage container"
  value       = azurerm_storage_container.containers["static-web"].name
}

output "static_web_app_url" {
  description = "URL of the Static Web App"
  value       = "https://${azurerm_static_web_app.web_cdp.default_host_name}"
}

output "static_web_app_custom_domain_url" {
  description = "Custom domain URL of the Static Web App (if enabled)"
  value       = var.enable_custom_domain ? "https://${var.static_web_app_custom_domain}" : "Custom domain not enabled"
}

output "dns_cname_record_instructions" {
  description = "Instructions for setting up DNS CNAME record"
  value = "To enable custom domain, create a CNAME record: web-cdp.ts-lucky.space -> ${azurerm_static_web_app.web_cdp.default_host_name}"
}