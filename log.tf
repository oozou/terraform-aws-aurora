resource "aws_cloudwatch_log_group" "this" {
  count             = var.is_create_cluster ? length(var.enabled_cloudwatch_logs_exports) : 0
  name              = format("/aws/rds/cluster/%s-cluster/%s", local.name, var.enabled_cloudwatch_logs_exports[count.index])
  retention_in_days = var.cloudwatch_log_retention_in_days
  kms_key_id        = var.cloudwatch_log_kms_key_id

  tags = local.tags
}
