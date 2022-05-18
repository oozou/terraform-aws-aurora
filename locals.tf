/* -------------------------------------------------------------------------- */
/*                                   LOCALS                                   */
/* -------------------------------------------------------------------------- */
locals {

  port        = coalesce(var.port, (var.engine == "aurora-postgresql" ? 5432 : 3306))
  name        = format("%s-%s-%s-db", var.prefix, var.environment, var.name)
  environment = var.environment



  is_create_random_master_password = var.master_password == ""
  master_password                  = var.is_create_cluster && local.is_create_random_master_password ? random_password.master_password[0].result : var.master_password
  db_subnet_group_name             = var.is_create_db_subnet_group ? join("", aws_db_subnet_group.this.*.name) : var.db_subnet_group_name
  rds_enhanced_monitoring_arn      = var.is_create_monitoring_role ? join("", aws_iam_role.rds_enhanced_monitoring.*.arn) : var.monitoring_role_arn
  rds_security_group_id            = join("", aws_security_group.this.*.id)
  is_serverless                    = var.engine_mode == "serverless"
  parameter_family                 = var.engine == "aurora-mysql" ? format("%s%s", var.engine, substr(var.engine_version, 0, 3)) : format("%s%s", var.engine, substr(var.engine_version, 0, 2))

  tags = merge(
    {
      Terraform   = true
      Environment = local.environment
    },
    var.tags
  )
}
