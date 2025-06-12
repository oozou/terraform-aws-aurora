locals {
  comparison_operators = {
    ">=" = "GreaterThanOrEqualToThreshold",
    ">"  = "GreaterThanThreshold",
    "<"  = "LessThanThreshold",
    "<=" = "LessThanOrEqualToThreshold",
  }

  # Default cluster alarms configuration
  default_cluster_alarms = var.is_enabled_default_alarm ? {
    cpu_utilization_too_high = {
      metric_name         = "CPUUtilization"
      statistic           = "Average"
      comparison_operator = ">="
      threshold           = "80"
      period              = "300"
      evaluation_periods  = "2"
      alarm_actions       = var.default_alarm_actions
      ok_actions          = var.default_ok_actions
    }
    database_connections_too_high = {
      metric_name         = "DatabaseConnections"
      statistic           = "Average"
      comparison_operator = ">="
      threshold           = "80"
      period              = "300"
      evaluation_periods  = "2"
      alarm_actions       = var.default_alarm_actions
      ok_actions          = var.default_ok_actions
    }
    read_latency_too_high = {
      metric_name         = "ReadLatency"
      statistic           = "Average"
      comparison_operator = ">="
      threshold           = "0.2"
      period              = "300"
      evaluation_periods  = "2"
      alarm_actions       = var.default_alarm_actions
      ok_actions          = var.default_ok_actions
    }
    write_latency_too_high = {
      metric_name         = "WriteLatency"
      statistic           = "Average"
      comparison_operator = ">="
      threshold           = "0.2"
      period              = "300"
      evaluation_periods  = "2"
      alarm_actions       = var.default_alarm_actions
      ok_actions          = var.default_ok_actions
    }
  } : {}

  # Default instance alarms configuration
  default_instance_alarms = var.is_enabled_default_alarm ? {
    freeable_memory_too_low = {
      metric_name         = "FreeableMemory"
      statistic           = "Average"
      comparison_operator = "<="
      threshold           = "104857600" # 100MB
      period              = "300"
      evaluation_periods  = "2"
      alarm_actions       = var.default_alarm_actions
      ok_actions          = var.default_ok_actions
    }
  } : {}

  # Merge default and custom configurations
  final_cluster_alarms = merge(local.default_cluster_alarms, var.custom_aurora_cluster_alarms_configure)
  final_instance_alarms = merge(local.default_instance_alarms, var.custom_aurora_instance_alarms_configure)
}

# Aurora Cluster Alarms
module "aurora_cluster_alarms" {
  source  = "oozou/cloudwatch-alarm/aws"
  version = "1.0.0"

  for_each   = var.is_create_cluster ? local.final_cluster_alarms : {}
  depends_on = [aws_rds_cluster.this[0]]

  prefix      = var.prefix
  environment = var.environment
  name        = format("%s-cluster-%s-alarm", local.name, each.key)

  alarm_description = format(
    "%s's %s %s %s in period %ss with %s datapoint",
    lookup(each.value, "metric_name", null),
    lookup(each.value, "statistic", "Average"),
    lookup(each.value, "comparison_operator", null),
    lookup(each.value, "threshold", null),
    lookup(each.value, "period", 600),
    lookup(each.value, "evaluation_periods", 1)
  )

  comparison_operator = local.comparison_operators[lookup(each.value, "comparison_operator", null)]
  evaluation_periods  = lookup(each.value, "evaluation_periods", 1)
  metric_name         = lookup(each.value, "metric_name", null)
  namespace           = "AWS/RDS"
  period              = lookup(each.value, "period", 600)
  statistic           = lookup(each.value, "statistic", "Average")
  threshold           = lookup(each.value, "threshold", null)

  dimensions = {
    DBClusterIdentifier = try(aws_rds_cluster.this[0].cluster_identifier, "")
  }

  alarm_actions = lookup(each.value, "alarm_actions", null)
  ok_actions    = lookup(each.value, "ok_actions", null)

  tags = local.tags
}

# Aurora Instance Alarms
module "aurora_instance_alarms" {
  source  = "oozou/cloudwatch-alarm/aws"
  version = "1.0.0"

  for_each = var.is_create_cluster && !local.is_serverless ? {
    for alarm_key, alarm_config in var.custom_aurora_instance_alarms_configure :
    alarm_key => merge(alarm_config, {
      instances = var.instances
    })
  } : {}

  depends_on = [aws_rds_cluster_instance.this]

  prefix      = var.prefix
  environment = var.environment
  name        = format("%s-instance-%s-alarm", local.name, each.key)

  alarm_description = format(
    "%s's %s %s %s in period %ss with %s datapoint",
    lookup(each.value, "metric_name", null),
    lookup(each.value, "statistic", "Average"),
    lookup(each.value, "comparison_operator", null),
    lookup(each.value, "threshold", null),
    lookup(each.value, "period", 600),
    lookup(each.value, "evaluation_periods", 1)
  )

  comparison_operator = local.comparison_operators[lookup(each.value, "comparison_operator", null)]
  evaluation_periods  = lookup(each.value, "evaluation_periods", 1)
  metric_name         = lookup(each.value, "metric_name", null)
  namespace           = "AWS/RDS"
  period              = lookup(each.value, "period", 600)
  statistic           = lookup(each.value, "statistic", "Average")
  threshold           = lookup(each.value, "threshold", null)

  dimensions = {
    # This will create alarms for all instances, but we'll handle this differently
    DBInstanceIdentifier = "placeholder"
  }

  alarm_actions = lookup(each.value, "alarm_actions", null)
  ok_actions    = lookup(each.value, "ok_actions", null)

  tags = local.tags
}

# Individual Instance Alarms (for metrics that need per-instance monitoring)
module "aurora_per_instance_alarms" {
  source  = "oozou/cloudwatch-alarm/aws"
  version = "1.0.0"

  for_each = var.is_create_cluster && !local.is_serverless ? {
    for combination in flatten([
      for instance_key, instance_config in var.instances : [
        for alarm_key, alarm_config in local.final_instance_alarms : {
          key           = "${instance_key}-${alarm_key}"
          instance_key  = instance_key
          alarm_key     = alarm_key
          alarm_config  = alarm_config
        }
      ]
    ]) : combination.key => combination
  } : {}

  depends_on = [aws_rds_cluster_instance.this]

  prefix      = var.prefix
  environment = var.environment
  name        = format("%s-instance-%s-%s-alarm", local.name, each.value.instance_key, each.value.alarm_key)

  alarm_description = format(
    "%s's %s %s %s in period %ss with %s datapoint for instance %s",
    lookup(each.value.alarm_config, "metric_name", null),
    lookup(each.value.alarm_config, "statistic", "Average"),
    lookup(each.value.alarm_config, "comparison_operator", null),
    lookup(each.value.alarm_config, "threshold", null),
    lookup(each.value.alarm_config, "period", 600),
    lookup(each.value.alarm_config, "evaluation_periods", 1),
    each.value.instance_key
  )

  comparison_operator = local.comparison_operators[lookup(each.value.alarm_config, "comparison_operator", null)]
  evaluation_periods  = lookup(each.value.alarm_config, "evaluation_periods", 1)
  metric_name         = lookup(each.value.alarm_config, "metric_name", null)
  namespace           = "AWS/RDS"
  period              = lookup(each.value.alarm_config, "period", 600)
  statistic           = lookup(each.value.alarm_config, "statistic", "Average")
  threshold           = lookup(each.value.alarm_config, "threshold", null)

  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster_instance.this[each.value.instance_key].identifier
  }

  alarm_actions = lookup(each.value.alarm_config, "alarm_actions", null)
  ok_actions    = lookup(each.value.alarm_config, "ok_actions", null)

  tags = local.tags
}
