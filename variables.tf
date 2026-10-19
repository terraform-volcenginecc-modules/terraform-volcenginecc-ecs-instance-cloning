variable "region" {
  description = "两种模式通用，可选。源资源及所有新建资源所在的地域。"
  type        = string
  default     = "cn-beijing"
  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "region 不能为空。"
  }
}

variable "clone_mode" {
  description = "两种模式通用，必填。CloneEcsInstance 使用原镜像和网络复制实例配置；CloneEcsDisk 为一块源云盘创建快照并据此创建一块新云盘。"
  type        = string
  validation {
    condition     = contains(["CloneEcsInstance", "CloneEcsDisk"], var.clone_mode)
    error_message = "clone_mode 必须为 CloneEcsInstance 或 CloneEcsDisk。"
  }
}

variable "source_instance_id" {
  description = "仅 CloneEcsInstance 模式必填。已有源 ECS 的只读 ID。"
  type        = string
  default     = null
  validation {
    condition     = var.source_instance_id == null ? true : can(regex("^i-[A-Za-z0-9]+$", var.source_instance_id)) && !can(regex("(?i)(replace|example|xxxx)", var.source_instance_id))
    error_message = "source_instance_id 必须为 null 或真实的 ECS ID。"
  }
}

variable "instance_count" {
  description = "仅 CloneEcsInstance 模式生效，可选。新建 ECS 实例的数量。"
  type        = number
  default     = 1
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 100 && floor(var.instance_count) == var.instance_count
    error_message = "instance_count 必须为 1 到 100 之间的整数。"
  }
}

variable "password" {
  description = "仅 CloneEcsInstance 模式必填。新实例的登录密码。"
  type        = string
  sensitive   = true
  default     = null
  validation {
    condition     = var.password == null ? true : length(var.password) >= 8 && length(var.password) <= 30
    error_message = "password 的长度必须为 8 到 30 个字符。"
  }
  validation {
    condition     = var.password == null ? true : can(regex("^[A-Za-z0-9`~!@#$%^&*()_+=|{}\\[\\]:;'<>,.?/\\-]+$", var.password)) && !startswith(var.password, "/") && !startswith(var.password, "$6$")
    error_message = "password 包含不支持的字符，或以禁止使用的前缀（'/' 或 '$6$'）开头。"
  }
  validation {
    condition = var.password == null ? true : (
      (can(regex("[A-Z]", var.password)) ? 1 : 0) +
      (can(regex("[a-z]", var.password)) ? 1 : 0) +
      (can(regex("[0-9]", var.password)) ? 1 : 0) +
      (can(regex("[`~!@#$%^&*()_+=|{}\\[\\]:;'<>,.?/\\-]", var.password)) ? 1 : 0)
    ) >= 3
    error_message = "password 必须包含以下四类字符中的至少三类：大写字母、小写字母、数字和允许使用的特殊字符。"
  }
}

variable "deletion_protection" {
  description = "仅 CloneEcsInstance 模式生效，可选。用于覆盖新 ECS 的删除保护设置；null 表示继承源实例设置。主动清理资源前请设为 false。"
  type        = bool
  default     = null
}

variable "source_volume_id" {
  description = "仅 CloneEcsDisk 模式必填。已有源云盘的 ID，源云盘内容不会被修改。"
  type        = string
  default     = null
  validation {
    condition     = var.source_volume_id == null ? true : can(regex("^vol-[A-Za-z0-9]+$", var.source_volume_id)) && !can(regex("(?i)(replace|example|xxxx)", var.source_volume_id))
    error_message = "source_volume_id 必须为 null 或真实的云盘 ID。"
  }
}

variable "disk_zone_id" {
  description = "仅 CloneEcsDisk 模式生效，可选。同一地域内目标云盘所在的可用区；null 表示沿用源云盘的可用区。"
  type        = string
  default     = null
  validation {
    condition     = var.disk_zone_id == null ? true : length(trimspace(var.disk_zone_id)) > 0
    error_message = "disk_zone_id 必须为 null 或非空的可用区 ID。"
  }
}

variable "disk_volume_type" {
  description = "仅 CloneEcsDisk 模式生效，可选。目标云盘类型；null 表示沿用源云盘类型。"
  type        = string
  default     = null
  validation {
    condition     = var.disk_volume_type == null ? true : contains(["ESSD_PL0", "ESSD_FlexPL", "TSSD_TL0"], var.disk_volume_type)
    error_message = "disk_volume_type 必须为 null、ESSD_PL0、ESSD_FlexPL 或 TSSD_TL0。"
  }
}
