# 提供两种克隆方式：克隆 ECS 配置，或克隆单块云盘的数据。
# 所有源资源及其网络资源均不纳入当前 Terraform State 管理。
locals {
  clone_instance = var.clone_mode == "CloneEcsInstance"
  clone_disk     = var.clone_mode == "CloneEcsDisk"
  source_eip_id  = local.clone_instance ? try(data.volcenginecc_ecs_instance.source[0].eip_address.allocation_id, null) : null
}

data "volcenginecc_ecs_instance" "source" {
  count = local.clone_instance ? 1 : 0
  id    = var.source_instance_id
  lifecycle {
    precondition {
      condition     = var.source_instance_id != null
      error_message = "CloneEcsInstance 模式必须提供 source_instance_id。"
    }
  }
}

data "volcenginecc_vpc_eip" "source" {
  count = local.clone_instance && local.source_eip_id != null && local.source_eip_id != "" ? 1 : 0
  id    = local.source_eip_id
}

# ECS 查询结果可能只提供系统盘 ID，因此需要继续读取系统盘的实际容量和存储类型，
# 避免目标资源的默认值覆盖源系统盘配置。
data "volcenginecc_storageebs_volume" "source_system" {
  count = local.clone_instance ? 1 : 0
  id    = data.volcenginecc_ecs_instance.source[0].system_volume.volume_id
}

module "compute" {
  count  = local.clone_instance ? 1 : 0
  source = "./modules/compute"

  source_instance_id    = data.volcenginecc_ecs_instance.source[0].instance_id
  instance_name         = data.volcenginecc_ecs_instance.source[0].instance_name
  instance_type         = data.volcenginecc_ecs_instance.source[0].instance_type
  zone_id               = data.volcenginecc_ecs_instance.source[0].zone_id
  image_id              = data.volcenginecc_ecs_instance.source[0].image.image_id
  image_release_version = data.volcenginecc_ecs_instance.source[0].image.image_release_version
  subnet_id             = data.volcenginecc_ecs_instance.source[0].primary_network_interface.subnet_id
  security_group_ids    = data.volcenginecc_ecs_instance.source[0].primary_network_interface.security_group_ids
  system_volume = {
    size        = data.volcenginecc_storageebs_volume.source_system[0].size
    volume_type = data.volcenginecc_storageebs_volume.source_system[0].volume_type
  }
  project_name         = data.volcenginecc_ecs_instance.source[0].project_name
  instance_charge_type = data.volcenginecc_ecs_instance.source[0].instance_charge_type
  period               = data.volcenginecc_ecs_instance.source[0].period
  period_unit          = data.volcenginecc_ecs_instance.source[0].period_unit
  auto_renew           = data.volcenginecc_ecs_instance.source[0].auto_renew
  auto_renew_period    = data.volcenginecc_ecs_instance.source[0].auto_renew_period
  spot_strategy        = data.volcenginecc_ecs_instance.source[0].spot_strategy
  spot_price_limit     = data.volcenginecc_ecs_instance.source[0].spot_price_limit
  eip_address = length(data.volcenginecc_vpc_eip.source) > 0 ? {
    allocation_id        = data.volcenginecc_vpc_eip.source[0].allocation_id
    bandwidth_mbps       = data.volcenginecc_vpc_eip.source[0].bandwidth
    bandwidth_package_id = data.volcenginecc_vpc_eip.source[0].bandwidth_package_id
    charge_type = lookup({
      "1" = "PrePaid"
      "2" = "PayByBandwidth"
      "3" = "PayByTraffic"
    }, tostring(data.volcenginecc_vpc_eip.source[0].billing_type), null)
    isp                             = data.volcenginecc_vpc_eip.source[0].isp
    release_with_instance           = data.volcenginecc_vpc_eip.source[0].release_with_instance
    security_protection_instance_id = data.volcenginecc_vpc_eip.source[0].security_protection_instance_id
    security_protection_types       = data.volcenginecc_vpc_eip.source[0].security_protection_types
  } : null
  deletion_protection = var.deletion_protection != null ? var.deletion_protection : data.volcenginecc_ecs_instance.source[0].deletion_protection
  instance_count      = var.instance_count
  password            = var.password
  tags                = data.volcenginecc_ecs_instance.source[0].tags
}

data "volcenginecc_storageebs_volume" "source" {
  count = local.clone_disk ? 1 : 0
  id    = var.source_volume_id
  lifecycle {
    precondition {
      condition     = var.source_volume_id != null
      error_message = "CloneEcsDisk 模式必须提供 source_volume_id。"
    }
    postcondition {
      condition     = contains(["available", "mounted", "attached"], self.status)
      error_message = "创建快照前，源云盘必须处于可用或已挂载状态。"
    }
  }
}

module "disk" {
  count  = local.clone_disk ? 1 : 0
  source = "./modules/disk"

  source_volume_id   = data.volcenginecc_storageebs_volume.source[0].volume_id
  source_volume_type = data.volcenginecc_storageebs_volume.source[0].volume_type
  zone_id            = var.disk_zone_id != null ? var.disk_zone_id : data.volcenginecc_storageebs_volume.source[0].zone_id
  volume_type        = var.disk_volume_type != null ? var.disk_volume_type : data.volcenginecc_storageebs_volume.source[0].volume_type
  size               = data.volcenginecc_storageebs_volume.source[0].size
  project_name       = data.volcenginecc_storageebs_volume.source[0].project_name
  tags               = data.volcenginecc_storageebs_volume.source[0].tags
}
