/* -------------------------------------------------------------------------- */
/*                                    DATA                                    */
/* -------------------------------------------------------------------------- */
# Ref. https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html#genref-aws-service-namespaces
data "aws_partition" "current" {}

/* -------------------------------------------------------------------------- */
/*                               RANDOM RESOURCE                              */
/* -------------------------------------------------------------------------- */
resource "random_password" "master_password" {
  count = var.is_create_cluster && var.is_create_random_password ? 1 : 0

  length  = var.random_password_length
  special = false
}

resource "random_id" "snapshot_identifier" {
  count = var.is_create_cluster ? 1 : 0

  keepers = {
    id = var.name
  }

  byte_length = 4
}

/* -------------------------------------------------------------------------- */
/*                                 RDS CLUSTER                                */
/* -------------------------------------------------------------------------- */
resource "aws_db_subnet_group" "this" {
  count = var.is_create_cluster && var.is_create_db_subnet_group ? 1 : 0

  name        = "${local.name}-cluster-sngroup"
  description = "Aurora cluster subnet group for ${local.name}"
  subnet_ids  = var.db_subnet_group_ids

  tags = merge(local.tags, { "Name" : "${local.name}-cluster-sngroup" })
}

resource "aws_rds_cluster" "this" {
  count = var.is_create_cluster ? 1 : 0

  cluster_identifier            = "${local.name}-cluster"
  replication_source_identifier = var.replication_source_identifier

  port               = local.port
  engine             = var.engine
  engine_mode        = var.engine_mode
  engine_version     = local.is_serverless ? null : var.engine_version
  availability_zones = var.availability_zones

  storage_encrypted = var.is_storage_encrypted
  kms_key_id        = var.kms_key_id

  database_name             = var.database_name
  master_username           = var.master_username
  master_password           = local.master_password
  db_subnet_group_name      = local.db_subnet_group_name
  final_snapshot_identifier = "${local.name}-final-${element(concat(random_id.snapshot_identifier.*.hex, [""]), 0)}"
  skip_final_snapshot       = var.is_skip_final_snapshot
  apply_immediately         = var.is_apply_immediately

  deletion_protection     = var.deletion_protection
  backup_retention_period = var.backup_retention_period

  preferred_backup_window      = local.is_serverless ? null : var.preferred_backup_window
  preferred_maintenance_window = local.is_serverless ? null : var.preferred_maintenance_window

  vpc_security_group_ids              = compact(concat(aws_security_group.server.*.id, var.vpc_security_group_ids))
  allow_major_version_upgrade         = var.is_allow_major_version_upgrade
  db_cluster_parameter_group_name     = var.is_create_db_cluster_parameter_group ? join("", aws_rds_cluster_parameter_group.this.*.id) : var.db_cluster_parameter_group_name
  db_instance_parameter_group_name    = var.is_allow_major_version_upgrade ? var.db_cluster_db_instance_parameter_group_name : null
  iam_database_authentication_enabled = var.is_iam_database_authentication_enabled
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports

  # Restore from snapshot or not
  snapshot_identifier = var.snapshot_identifier

  # serverless auto scaling configuration
  dynamic "scaling_configuration" {
    for_each = length(keys(var.scaling_configuration)) == 0 || !local.is_serverless ? [] : [var.scaling_configuration]

    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", null)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", null)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", null)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", null)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", null)
    }
  }

  # Restore to the point at the specific time
  dynamic "restore_to_point_in_time" {
    for_each = length(keys(var.restore_to_point_in_time)) == 0 ? [] : [var.restore_to_point_in_time]

    content {
      source_cluster_identifier  = restore_to_point_in_time.value.source_cluster_identifier
      restore_type               = lookup(restore_to_point_in_time.value, "restore_type", null)
      use_latest_restorable_time = lookup(restore_to_point_in_time.value, "use_latest_restorable_time", null)
      restore_to_time            = lookup(restore_to_point_in_time.value, "restore_to_time", null)
    }
  }

  lifecycle {
    ignore_changes = [
      # See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster#replication_source_identifier
      replication_source_identifier,
    ]
  }

  tags                  = merge(local.tags, { "Name" : "${var.database_name}" })
  copy_tags_to_snapshot = var.is_copy_tags_to_snapshot
  depends_on = [
    aws_cloudwatch_log_group.this
  ]
}

/* -------------------------------------------------------------------------- */
/*                              CLUSTER INSTNACE                              */
/* -------------------------------------------------------------------------- */
resource "aws_rds_cluster_instance" "this" {
  for_each = var.is_create_cluster && !local.is_serverless ? var.instances : {}

  identifier                            = var.is_instances_use_identifier_prefix ? null : lookup(each.value, "identifier", "${local.name}-${each.key}")
  identifier_prefix                     = var.is_instances_use_identifier_prefix ? lookup(each.value, "identifier_prefix", "${local.name}-${each.key}-") : null
  cluster_identifier                    = aws_rds_cluster.this[0].id
  engine                                = var.engine
  engine_version                        = var.engine_version
  instance_class                        = lookup(each.value, "instance_class", var.instance_class)
  publicly_accessible                   = lookup(each.value, "publicly_accessible", var.publicly_accessible)
  db_subnet_group_name                  = local.db_subnet_group_name
  db_parameter_group_name               = var.is_create_db_parameter_group ? join("", aws_db_parameter_group.this.*.id) : lookup(each.value, "db_parameter_group_name", var.db_parameter_group_name)
  apply_immediately                     = lookup(each.value, "apply_immediately", var.is_apply_immediately)
  monitoring_role_arn                   = local.rds_enhanced_monitoring_arn
  monitoring_interval                   = lookup(each.value, "monitoring_interval", var.monitoring_interval)
  promotion_tier                        = lookup(each.value, "promotion_tier", null)
  availability_zone                     = lookup(each.value, "availability_zone", null)
  preferred_maintenance_window          = lookup(each.value, "preferred_maintenance_window", var.preferred_maintenance_window)
  auto_minor_version_upgrade            = lookup(each.value, "auto_minor_version_upgrade", var.auto_minor_version_upgrade)
  performance_insights_enabled          = lookup(each.value, "performance_insights_enabled", var.performance_insights_enabled)
  performance_insights_kms_key_id       = lookup(each.value, "performance_insights_kms_key_id", var.performance_insights_kms_key_id)
  performance_insights_retention_period = lookup(each.value, "performance_insights_retention_period", var.performance_insights_retention_period)
  copy_tags_to_snapshot                 = lookup(each.value, "copy_tags_to_snapshot", var.is_copy_tags_to_snapshot)
  ca_cert_identifier                    = var.ca_cert_identifier

  tags = local.tags
}

/* -------------------------------------------------------------------------- */
/*                              CLUSTER ENDPOINTS                             */
/* -------------------------------------------------------------------------- */
resource "aws_rds_cluster_endpoint" "this" {
  for_each = var.is_create_cluster && !local.is_serverless ? var.endpoints : tomap({})

  depends_on = [
    aws_rds_cluster_instance.this
  ]

  cluster_identifier          = try(aws_rds_cluster.this[0].id, "")
  cluster_endpoint_identifier = each.value.identifier
  custom_endpoint_type        = each.value.type

  static_members   = lookup(each.value, "static_members", null)
  excluded_members = lookup(each.value, "excluded_members", null)

  tags = local.tags
}

/* -------------------------------------------------------------------------- */
/*                                IAM ROLE ASSO                               */
/* -------------------------------------------------------------------------- */
resource "aws_rds_cluster_role_association" "this" {
  for_each = var.is_create_cluster ? var.iam_roles : {}

  db_cluster_identifier = try(aws_rds_cluster.this[0].id, "")
  feature_name          = each.value.feature_name
  role_arn              = each.value.role_arn
}

/* -------------------------------------------------------------------------- */
/*                                 MONITORING                                 */
/* -------------------------------------------------------------------------- */
data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count       = var.is_create_cluster && var.is_create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0
  name        = "${local.name}-cluster-monitoring-role"
  description = "Role created to monitor the RDS"
  path        = "/"

  assume_role_policy    = data.aws_iam_policy_document.monitoring_rds_assume_role.json
  managed_policy_arns   = var.iam_role_managed_policy_arns
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration

  tags = merge(local.tags, { "Name" : "${local.name}-cluster-monitoring-role" })
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = var.is_create_cluster && var.is_create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

/* -------------------------------------------------------------------------- */
/*                                AUTO SCALING                                */
/* -------------------------------------------------------------------------- */
resource "aws_appautoscaling_policy" "this" {
  count = var.is_create_cluster && var.is_autoscaling_enabled && !local.is_serverless ? 1 : 0

  depends_on = [
    aws_appautoscaling_target.this
  ]

  name               = "target-metric"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "cluster:${try(aws_rds_cluster.this[0].cluster_identifier, "")}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.predefined_metric_type
    }

    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
    target_value       = var.predefined_metric_type == "RDSReaderAverageCPUUtilization" ? var.autoscaling_target_cpu : var.autoscaling_target_connections
  }
}

resource "aws_appautoscaling_target" "this" {
  count = var.is_create_cluster && var.is_autoscaling_enabled && !local.is_serverless ? 1 : 0

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "cluster:${try(aws_rds_cluster.this[0].cluster_identifier, "")}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}


/* -------------------------------------------------------------------------- */
/*                           AWS_DB_PARAMETER_GROUP                           */
/* -------------------------------------------------------------------------- */
resource "aws_db_parameter_group" "this" {
  count = var.is_create_cluster && var.is_create_db_parameter_group ? 1 : 0

  name        = "${local.name}-param"
  description = format("Database parameter group for %s", local.name)
  family      = local.parameter_family

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(local.tags, { Name = "${local.name}-param" })
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.is_create_cluster && var.is_create_db_cluster_parameter_group ? 1 : 0

  name        = "${local.name}-cluster-param"
  family      = local.parameter_family
  description = format("Database Cluster parameter group for %s", local.name)

  dynamic "parameter" {
    for_each = var.db_cluster_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(local.tags, { Name = "${local.name}-cluster-param" })
}
