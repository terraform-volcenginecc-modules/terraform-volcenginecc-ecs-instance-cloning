# 为一块已有云盘创建快照，并据此恢复出一块未挂载的新数据盘。
resource "volcenginecc_storageebs_snapshot" "this" {
  volume_id     = var.source_volume_id
  snapshot_name = "clone-${var.source_volume_id}"
  project_name  = var.project_name
  tags          = var.tags == null ? null : (length(var.tags) > 0 ? var.tags : null)
  lifecycle {
    precondition {
      condition     = contains(["ESSD_PL0", "ESSD_FlexPL", "TSSD_TL0"], var.source_volume_type)
      error_message = "源云盘必须支持快照；不支持 PTSSD。"
    }
  }
}

resource "volcenginecc_storageebs_volume" "this" {
  volume_name        = "clone-${var.source_volume_id}"
  zone_id            = var.zone_id
  volume_type        = var.volume_type
  size               = var.size
  kind               = "data"
  pay_type           = "post"
  project_name       = var.project_name
  source_snapshot_id = volcenginecc_storageebs_snapshot.this.snapshot_id
  tags               = var.tags == null ? null : (length(var.tags) > 0 ? var.tags : null)
  lifecycle {
    precondition {
      condition     = volcenginecc_storageebs_snapshot.this.status == "available"
      error_message = "创建克隆云盘前，源快照必须处于可用状态。"
    }
    precondition {
      condition     = contains(["ESSD_PL0", "ESSD_FlexPL", "TSSD_TL0"], var.volume_type) && var.size >= (var.volume_type == "TSSD_TL0" ? 40 : 10)
      error_message = "目标云盘类型必须受支持，且继承自源云盘的容量必须达到该类型的最小容量要求。"
    }
  }
}
