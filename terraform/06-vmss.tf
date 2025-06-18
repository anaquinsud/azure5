# ============================================================================
# VIRTUAL MACHINE SCALE SET (VMSS)
# ============================================================================

# Virtual Machine Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                = local.vmss_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.vm_size
  instances           = var.vmss_instance_count
  
  # Zone configuration for High Availability
  zones                        = var.availability_zones
  zone_balance                 = true
  # platform_fault_domain_count = 1
  single_placement_group = false

  # Auto-scaling settings
  upgrade_mode = "Automatic"
  
  # Health checks
  health_probe_id = azurerm_lb_probe.probes["http"].id
  
  # Admin configuration
  admin_username                  = var.vm_admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.vm_ssh_public_key
  }

  # Network configuration
  network_interface {
    name    = "internal"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.private.id
      
      # Load Balancer Backend Pool
      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.main.id
      ]
      
      # SSH NAT Pool (ถ้าต้องการ)
      load_balancer_inbound_nat_rules_ids = var.enable_vmss_ssh_access ? [
        azurerm_lb_nat_pool.ssh[0].id
      ] : []
    }
  }

  # OS Disk configuration
  os_disk {
    storage_account_type = var.storage_type
    caching              = "ReadWrite"
    disk_size_gb         = var.vm_disk_size
  }

  # Source image
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Cloud-init for basic setup (nginx จะไป remote install เอง)
  custom_data = base64encode(var.cloud_init_script)

  tags = local.common_tags
}

# Auto-scaling configuration
resource "azurerm_monitor_autoscale_setting" "vmss" {
  count               = var.enable_autoscaling ? 1 : 0
  name                = "${local.vmss_name}-autoscale"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.main.id

  profile {
    name = "default"

    capacity {
      default = var.vmss_instance_count
      minimum = var.vmss_min_instances
      maximum = var.vmss_max_instances
    }

    # Scale Out Rule - เพิ่ม instance เมื่อ CPU สูง
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "2"  # เพิ่มทีละ 3 (1 per zone)
        cooldown  = "PT10M"
      }
    }

    # Scale In Rule - ลด instance เมื่อ CPU ต่ำ
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT15M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "2"  # ลดทีละ 3 (แต่ไม่ต่ำกว่า minimum)
        cooldown  = "PT15M"
      }
    }
  }

  # Schedule-based scaling สำหรับ peak hours
  dynamic "profile" {
    for_each = var.enable_scheduled_scaling ? [1] : []
    content {
      name = "business-hours"

      capacity {
        default = var.vmss_max_instances
        minimum = var.vmss_min_instances
        maximum = var.vmss_max_instances
      }

      recurrence {
        timezone = "SE Asia Standard Time"
        days     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        hours    = [9]   # 9 AM
        minutes  = [0]
      }
    }
  }

  # Off-hours profile (ลดลง)
  dynamic "profile" {
    for_each = var.enable_scheduled_scaling ? [1] : []
    content {
      name = "off-hours"

      capacity {
        default = var.vmss_min_instances  # กลับมา minimum
        minimum = var.vmss_min_instances
        maximum = var.vmss_min_instances
      }

      recurrence {
        timezone = "SE Asia Standard Time"
        days     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        hours    = [18]  # 6 PM
        minutes  = [0]
      }
    }
  }

  tags = local.common_tags
}