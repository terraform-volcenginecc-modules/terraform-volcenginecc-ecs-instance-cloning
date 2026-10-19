# 复用源实例配置和已有网络，不在此处纳管任何源资源。
locals {
  prepaid             = var.instance_charge_type == "PrePaid"
  postpaid            = var.instance_charge_type == "PostPaid"
  source_has_eip      = var.eip_address != null && try(var.eip_address.allocation_id, null) != null && try(var.eip_address.allocation_id, "") != ""
  valid_periods       = [1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 24, 36, 48, 60]
  valid_renew_periods = [1, 2, 3, 6, 12]
}

resource "volcenginecc_ecs_instance" "this" {
  count                = var.instance_count
  instance_name        = "${substr(var.instance_name, 0, 112)}-clone-${format("%03d", count.index + 1)}"
  description          = "源实例 ${var.source_instance_id} 的配置克隆"
  instance_type        = var.instance_type
  instance_charge_type = var.instance_charge_type
  period               = local.prepaid ? (contains(local.valid_periods, coalesce(var.period, 1)) ? coalesce(var.period, 1) : 1) : null
  period_unit          = local.prepaid ? coalesce(var.period_unit, "Month") : null
  auto_renew           = local.prepaid ? coalesce(var.auto_renew, false) : null
  auto_renew_period    = local.prepaid && coalesce(var.auto_renew, false) ? (contains(local.valid_renew_periods, coalesce(var.auto_renew_period, 1)) ? coalesce(var.auto_renew_period, 1) : 1) : null
  spot_strategy        = local.postpaid ? coalesce(var.spot_strategy, "NoSpot") : null
  spot_price_limit     = local.postpaid && var.spot_strategy == "SpotWithPriceLimit" ? var.spot_price_limit : null
  zone_id              = var.zone_id
  project_name         = var.project_name
  password             = var.password
  deletion_protection  = var.deletion_protection
  tags                 = var.tags == null ? null : (length(var.tags) > 0 ? var.tags : null)

  image = {
    image_id              = var.image_id
    image_release_version = var.image_release_version
    keep_image_credential = false
  }
  primary_network_interface = {
    subnet_id          = var.subnet_id
    security_group_ids = var.security_group_ids
  }
  # 一个源 EIP 不能同时绑定两台实例，因此按相同的可配置属性申请新 EIP，
  # 并忽略只读的分配 ID 和 IP 地址字段。
  eip_address = local.source_has_eip ? {
    bandwidth_mbps                  = coalesce(var.eip_address.bandwidth_mbps, 1)
    bandwidth_package_id            = var.eip_address.bandwidth_package_id
    charge_type                     = coalesce(var.eip_address.charge_type, "PayByBandwidth")
    isp                             = coalesce(var.eip_address.isp, "BGP")
    release_with_instance           = coalesce(var.eip_address.release_with_instance, false)
    security_protection_instance_id = try(contains(var.eip_address.security_protection_types, "AntiDDoS_Enhanced"), false) ? var.eip_address.security_protection_instance_id : null
    security_protection_types       = try(length(var.eip_address.security_protection_types), 0) > 0 ? var.eip_address.security_protection_types : null
  } : null
  system_volume = {
    size                 = var.system_volume.size
    volume_type          = var.system_volume.volume_type
    delete_with_instance = true
  }

  lifecycle {
    precondition {
      condition     = var.password != null
      error_message = "CloneEcsInstance 模式必须通过安全的运行时输入提供新登录密码。"
    }
  }
}
