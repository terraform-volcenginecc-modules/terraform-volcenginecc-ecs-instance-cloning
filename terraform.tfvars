# 全部参数均显式列出，由 clone_mode 决定使用 ECS 参数还是云盘参数。
# 云凭证通过 VOLCENGINE_ACCESS_KEY / VOLCENGINE_SECRET_KEY 注入，不写入本文件。

# -----------------------------------------------------------------------------
# 通用配置
# -----------------------------------------------------------------------------

region     = "cn-beijing"       # 两种模式通用，可选；默认 cn-beijing
clone_mode = "CloneEcsInstance" # 两种模式通用，必填；当前选择 CloneEcsInstance

# 标签自动继承源 ECS 或源云盘，无需填写。

# -----------------------------------------------------------------------------
# ECS 配置克隆（clone_mode = "CloneEcsInstance"）
# -----------------------------------------------------------------------------
# 复用源规格、原镜像、子网和安全组，不复制源盘当前新增的数据。
# 仅 CloneEcsInstance 模式必填；新登录密码通过 TF_VAR_password 注入，不写入本文件。

source_instance_id  = null # 仅 CloneEcsInstance 模式必填；替换为真实源 ECS ID
instance_count      = 1    # 仅 CloneEcsInstance 模式生效，可选；范围 1–100
deletion_protection = null # 仅 CloneEcsInstance 模式生效，可选；null 表示继承源实例

# -----------------------------------------------------------------------------
# 单盘克隆（clone_mode = "CloneEcsDisk"）
# -----------------------------------------------------------------------------
# 使用本模式时，将 clone_mode 修改为 CloneEcsDisk，并填写真实源云盘 ID。
# 从源盘制作快照并创建一块新数据盘，不创建 ECS，不自动挂载。

source_volume_id = null # 仅 CloneEcsDisk 模式必填；替换为真实源云盘 ID
disk_zone_id     = null # 仅 CloneEcsDisk 模式生效，可选；null 表示沿用源盘可用区
disk_volume_type = null # 仅 CloneEcsDisk 模式生效，可选；null 表示沿用源盘类型
