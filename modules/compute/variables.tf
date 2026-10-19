variable "source_instance_id" {
  description = "用于标识配置来源的只读源实例 ID。"
  type        = string
}
variable "instance_name" {
  description = "源实例名称；克隆后缀自动生成。"
  type        = string
}
variable "instance_type" {
  description = "源实例规格。"
  type        = string
}
variable "zone_id" {
  description = "源实例所在的可用区，与已有子网一致。"
  type        = string
}
variable "image_id" {
  description = "源实例的原镜像 ID。"
  type        = string
}
variable "image_release_version" {
  description = "源镜像的发布版本；用于将公共镜像固定到与源实例完全相同的版本。"
  type        = string
}
variable "subnet_id" {
  description = "需要复用的已有源子网。"
  type        = string
}
variable "security_group_ids" {
  description = "需要复用的源实例主网卡全部已有安全组。"
  type        = set(string)
}
variable "system_volume" {
  description = "源实例的系统盘配置。"
  type        = object({ size = number, volume_type = string })
}
variable "project_name" {
  description = "源实例所属项目名称。"
  type        = string
}
variable "instance_charge_type" {
  description = "源实例的计费类型。"
  type        = string
}
variable "period" {
  description = "源实例的包年包月购买时长（如有）。"
  type        = number
}
variable "period_unit" {
  description = "源实例的包年包月购买时长单位（如有）。"
  type        = string
}
variable "auto_renew" {
  description = "源实例的包年包月自动续费设置。"
  type        = bool
}
variable "auto_renew_period" {
  description = "源实例的包年包月自动续费周期（如有）。"
  type        = number
}
variable "spot_strategy" {
  description = "源实例的按量付费抢占式实例策略。"
  type        = string
}
variable "spot_price_limit" {
  description = "源实例的抢占式实例出价上限（如适用）。"
  type        = number
}
variable "eip_address" {
  description = "源 EIP 配置。不复用只读的分配 ID 和地址值。"
  type = object({
    allocation_id                   = string
    bandwidth_mbps                  = number
    bandwidth_package_id            = string
    charge_type                     = string
    isp                             = string
    release_with_instance           = bool
    security_protection_instance_id = number
    security_protection_types       = set(string)
  })
}
variable "instance_count" {
  description = "新建实例的数量。"
  type        = number
}
variable "password" {
  description = "新实例的登录密码；不继承源实例凭证。"
  type        = string
  sensitive   = true
}
variable "deletion_protection" {
  description = "新实例的删除保护设置。"
  type        = bool
}
variable "tags" {
  description = "新实例继承的源 ECS 标签。"
  type        = set(object({ key = string, value = string }))
  default     = null
}
