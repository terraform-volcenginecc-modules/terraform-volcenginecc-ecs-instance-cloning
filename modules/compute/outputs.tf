output "instance_ids" {
  description = "新建 ECS 实例的 ID。"
  value       = volcenginecc_ecs_instance.this[*].instance_id
}
output "instances" {
  description = "新实例的标识、状态、计费、保护、网络、EIP 和云盘清单，不包含密码。"
  value = [for instance in volcenginecc_ecs_instance.this : {
    instance_id          = instance.instance_id
    instance_name        = instance.instance_name
    status               = instance.status
    zone_id              = instance.zone_id
    instance_type        = instance.instance_type
    instance_charge_type = instance.instance_charge_type
    spot_strategy        = instance.spot_strategy
    deletion_protection  = instance.deletion_protection
    image_id             = instance.image.image_id
    subnet_id            = instance.primary_network_interface.subnet_id
    security_group_ids   = instance.primary_network_interface.security_group_ids
    network_interface_id = instance.primary_network_interface.network_interface_id
    primary_ip_address   = instance.primary_network_interface.primary_ip_address
    private_ip_addresses = instance.primary_network_interface.private_ip_addresses
    eip_address          = instance.eip_address
    system_volume        = instance.system_volume
    data_volumes         = instance.data_volumes
  }]
}
