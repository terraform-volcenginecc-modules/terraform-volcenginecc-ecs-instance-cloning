variable "source_volume_id" {
  description = "只读的源云盘 ID。"
  type        = string
}
variable "source_volume_type" {
  description = "用于校验快照支持情况的源云盘类型。"
  type        = string
}
variable "zone_id" {
  description = "目标云盘所在的可用区。"
  type        = string
}
variable "volume_type" {
  description = "目标云盘的存储类型。"
  type        = string
}
variable "size" {
  description = "源云盘容量，单位为 GiB；继承时不缩容。"
  type        = number
}
variable "project_name" {
  description = "源云盘所属项目，同时用于快照和克隆云盘。"
  type        = string
}
variable "tags" {
  description = "新快照和克隆云盘继承的源云盘标签。"
  type        = set(object({ key = string, value = string }))
  default     = null
}
