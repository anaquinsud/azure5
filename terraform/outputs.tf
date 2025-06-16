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
# VIRTUAL MACHINE OUTPUTS
# ============================================================================

output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_private_ip" {
  description = "Private IP address of the virtual machine"
  value       = azurerm_network_interface.vm.private_ip_address
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_public_ip" {
  description = "Public IP address of the virtual machine (if enabled)"
  value       = var.enable_vm_public_ip ? azurerm_public_ip.vm[0].ip_address : null
}

output "vm_ssh_connection" {
  description = "SSH connection string for the VM"
  value       = var.enable_vm_public_ip ? "ssh ${var.vm_admin_username}@${azurerm_public_ip.vm[0].ip_address}" : "Use Azure Bastion or VPN to connect to private IP: ${azurerm_network_interface.vm.private_ip_address}"
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
    }
  }
}

# ============================================================================
# LOAD BALANCER OUTPUTS
# ============================================================================

output "load_balancer_id" {
  description = "ID of the load balancer"
  value       = azurerm_lb.main.id
}

output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer"
  value       = azurerm_public_ip.lb.ip_address
}

output "load_balancer_frontend_ip" {
  description = "Frontend IP configuration of the load balancer"
  value       = azurerm_lb.main.frontend_ip_configuration[0].private_ip_address
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