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

output "private_subnets" {
  description = "Information about private subnets"
  value = {
    for zone, subnet in azurerm_subnet.private :
    zone => {
      id           = subnet.id
      name         = subnet.name
      address_prefix = subnet.address_prefixes[0]
      zone         = zone
    }
  }
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
# VIRTUAL MACHINE OUTPUTS (LOOP-BASED)
# ============================================================================

output "virtual_machines" {
  description = "Information about all VMs (loop-based)"
  value = {
    for vm_key, vm_config in local.virtual_machines :
    vm_key => {
      id         = azurerm_linux_virtual_machine.main[vm_key].id
      name       = azurerm_linux_virtual_machine.main[vm_key].name
      private_ip = azurerm_network_interface.vm[vm_key].private_ip_address
      public_ip  = var.enable_vm_public_ip ? azurerm_public_ip.vm[vm_key].ip_address : null
      zone       = azurerm_linux_virtual_machine.main[vm_key].zone
      subnet_id  = azurerm_network_interface.vm[vm_key].ip_configuration[0].subnet_id
      subnet_name = azurerm_subnet.private[vm_config.subnet_key].name
    }
  }
}

output "vm_ssh_connections" {
  description = "SSH connection strings for all VMs (loop-based)"
  value = {
    for vm_key, vm_config in local.virtual_machines :
    vm_key => var.enable_vm_public_ip ? 
      "ssh ${vm_config.admin_username}@${azurerm_public_ip.vm[vm_key].ip_address}" : 
      "Use Azure Bastion or VPN to connect to private IP: ${azurerm_network_interface.vm[vm_key].private_ip_address}"
  }
}

# Legacy outputs for backward compatibility (first VM)
locals {
  first_vm_key = keys(local.virtual_machines)[0]
}

output "vm_id" {
  description = "ID of the first virtual machine"
  value       = azurerm_linux_virtual_machine.main[local.first_vm_key].id
}

output "vm_private_ip" {
  description = "Private IP address of the first virtual machine"
  value       = azurerm_network_interface.vm[local.first_vm_key].private_ip_address
}

output "vm_name" {
  description = "Name of the first virtual machine"
  value       = azurerm_linux_virtual_machine.main[local.first_vm_key].name
}

output "vm_public_ip" {
  description = "Public IP address of the first virtual machine (if enabled)"
  value       = var.enable_vm_public_ip ? azurerm_public_ip.vm[local.first_vm_key].ip_address : null
}

output "vm_ssh_connection" {
  description = "SSH connection string for the first VM"
  value       = var.enable_vm_public_ip ? "ssh ${local.virtual_machines[local.first_vm_key].admin_username}@${azurerm_public_ip.vm[local.first_vm_key].ip_address}" : "Use Azure Bastion or VPN to connect to private IP: ${azurerm_network_interface.vm[local.first_vm_key].private_ip_address}"
}

# ============================================================================
# CONTAINER APPS OUTPUTS
# ============================================================================

output "container_app_environment_id" {
  description = "ID of the Container Apps environment"
  value       = azurerm_container_app_environment.main.id
}

# All container apps output
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

# # Individual app outputs for backward compatibility
# output "golang_api_fqdn" {
#   description = "FQDN of the Golang API Container App"
#   value       = azurerm_container_app.apps["golang-api"].latest_revision_fqdn
# }

# output "nodejs_api_fqdn" {
#   description = "FQDN of the Node.js API Container App"
#   value       = azurerm_container_app.apps["nodejs-api"].latest_revision_fqdn
# }

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
# STORAGE OUTPUTS
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

# All storage containers output
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

# Main container for backward compatibility
output "storage_container_name" {
  description = "Name of the main storage container"
  value       = azurerm_storage_container.containers["main"].name
}

# ============================================================================
# SERVICE BUS OUTPUTS
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

# All queues output
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

# # Individual queues for backward compatibility
# output "cdp_queue_survey_tracking_name" {
#   description = "Name of the CDP queue survey tracking"
#   value       = azurerm_servicebus_queue.queues["cdp-queue-survey-tracking"].name
# }

# output "crm_otp_queue_name" {
#   description = "Name of the CRM OTP queue"
#   value       = azurerm_servicebus_queue.queues["crm-otp-queue"].name
# }

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

output "static_web_app_default_host_name" {
  description = "Default hostname of the Static Web App"
  value       = azurerm_static_web_app.web_cdp.default_host_name
}

output "static_web_app_api_key" {
  description = "API key for the Static Web App deployment"
  value       = azurerm_static_web_app.web_cdp.api_key
  sensitive   = true
}

output "static_web_app_url" {
  description = "URL of the Static Web App"
  value       = "https://${azurerm_static_web_app.web_cdp.default_host_name}"
}

# ============================================================================
# BASTION OUTPUTS
# ============================================================================

output "bastion_enabled" {
  description = "Whether Azure Bastion is enabled"
  value       = var.enable_bastion
}

output "bastion_public_ip" {
  description = "Public IP address of the Bastion host (if enabled)"
  value       = var.enable_bastion ? azurerm_public_ip.bastion[0].ip_address : null
}

output "bastion_fqdn" {
  description = "FQDN of the Bastion host (if enabled)"
  value       = var.enable_bastion ? azurerm_public_ip.bastion[0].fqdn : null
}

output "container_app_environment_static_ip" {
  description = "Static IP address of the private Container Apps environment"
  value       = azurerm_container_app_environment.main.static_ip_address
}