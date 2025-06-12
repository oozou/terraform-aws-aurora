locals {
  comparison_operators = {
    ">=" = "GreaterThanOrEqualToThreshold",
    ">"  = "GreaterThanThreshold",
    "<"  = "LessThanThreshold",
    "<=" = "LessThanOrEqualToThreshold",
  }
}

# Aurora Cluster Alarms
module "aurora_cluster_alarms" {
  source  = "oozou/cloudwatch-alarm/aws"
  version = "1.0.0"

  for_each   = var.is_create_cluster ? var.custom_aurora_cluster_alarms_configure : {}
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
        for alarm_key, alarm_config in var.custom_aurora_instance_alarms_configure : {
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
