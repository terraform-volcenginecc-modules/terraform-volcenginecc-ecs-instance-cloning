output "volume_id" {
  description = "新建且未挂载的数据盘 ID。"
  value       = volcenginecc_storageebs_volume.this.volume_id
}
output "snapshot_id" {
  description = "根据源云盘创建的快照 ID。"
  value       = volcenginecc_storageebs_snapshot.this.snapshot_id
}
output "volume" {
  description = "供读取的克隆云盘元数据。"
  value = {
    volume_id   = volcenginecc_storageebs_volume.this.volume_id
    snapshot_id = volcenginecc_storageebs_volume.this.source_snapshot_id
    status      = volcenginecc_storageebs_volume.this.status
    zone_id     = volcenginecc_storageebs_volume.this.zone_id
    volume_type = volcenginecc_storageebs_volume.this.volume_type
    size        = volcenginecc_storageebs_volume.this.size
  }
}
