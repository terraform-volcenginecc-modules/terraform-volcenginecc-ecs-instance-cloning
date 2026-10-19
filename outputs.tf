output "clone_mode" {
  description = "当前选择的克隆模式。"
  value       = var.clone_mode
}
output "cloned_instance_ids" {
  description = "实例模式下新建 ECS 的 ID；云盘模式下为空列表。"
  value       = local.clone_instance ? module.compute[0].instance_ids : []
}
output "cloned_instances" {
  description = "新 ECS 的状态、计费、保护、网络、EIP 和云盘元数据；云盘模式下为空列表。"
  value       = local.clone_instance ? module.compute[0].instances : []
}
output "reused_network" {
  description = "复用但不纳管、不修改的已有网络；云盘模式下为 null。"
  value = local.clone_instance ? {
    vpc_id             = data.volcenginecc_ecs_instance.source[0].vpc_id
    subnet_id          = data.volcenginecc_ecs_instance.source[0].primary_network_interface.subnet_id
    security_group_ids = data.volcenginecc_ecs_instance.source[0].primary_network_interface.security_group_ids
  } : null
}
output "source_image_id" {
  description = "新 ECS 使用的源实例原镜像，并非新备份；云盘模式下为 null。"
  value       = local.clone_instance ? data.volcenginecc_ecs_instance.source[0].image.image_id : null
}
output "cloned_volume_id" {
  description = "云盘模式下新建且未挂载的云盘 ID；实例模式下为 null。"
  value       = local.clone_disk ? module.disk[0].volume_id : null
}
output "snapshot_id" {
  description = "云盘模式下创建的快照 ID；实例模式下为 null。"
  value       = local.clone_disk ? module.disk[0].snapshot_id : null
}
output "cloned_volume" {
  description = "云盘模式下新建云盘的元数据；实例模式下为 null。"
  value       = local.clone_disk ? module.disk[0].volume : null
}
