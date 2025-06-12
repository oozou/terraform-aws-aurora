# Aurora CloudWatch Alarms
# CPU Utilization Alarm
module "aurora_cpu_alarm" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  source  = "oozou/cloudwatch-alarm/aws"
  version = "1.0.0"

  prefix      = var.prefix
  environment = var.environment
  name        = "${var.name}-aurora-cpu-utilization"

  alarm_description   = "Aurora cluster CPU utilization is too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cpu_alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = try(aws_rds_cluster.this[0].cluster_identifier, "")
  }

  tags = merge(local.tags, {
    Name = "${var.name}-aurora-cpu-utilization"
  })
}

# Memory Usage Alarm (DatabaseConnections as proxy for memory pressure)
module "aurora_database_connections_alarm" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  source  = "oozou/cloudwatch-alarm/aws"
  version = "1.0.0"

  prefix      = var.prefix
  environment = var.environment
  name        = "${var.name}-aurora-database-connections"

  alarm_description   = "Aurora cluster database connections are too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.connections_alarm_evaluation_periods
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = var.connections_alarm_period
  statistic           = "Average"
  threshold           = var.connections_alarm_threshold
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = try(aws_rds_cluster.this[0].cluster_identifier, "")
  }

  tags = merge(local.tags, {
    Name = "${var.name}-aurora-database-connections"
  })
}

# Freeable Memory Alarm (for instances)
module "aurora_freeable_memory_alarm" {
  for_each = var.enable_cloudwatch_alarms && !local.is_serverless ? var.instances : {}

  source  = "oozou/cloudwatch-alarm/aws"
  version = "1.0.0"

  prefix      = var.prefix
  environment = var.environment
  name        = "${var.name}-aurora-freeable-memory-${each.key}"

  alarm_description   = "Aurora instance ${each.key} freeable memory is too low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.memory_alarm_evaluation_periods
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = var.memory_alarm_period
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster_instance.this[each.key].identifier
  }

  tags = merge(local.tags, {
    Name = "${var.name}-aurora-freeable-memory-${each.key}"
  })
}

# Read Latency Alarm
module "aurora_read_latency_alarm" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  source  = "oozou/cloudwatch-alarm/aws"
  version = "1.0.0"

  prefix      = var.prefix
  environment = var.environment
  name        = "${var.name}-aurora-read-latency"

  alarm_description   = "Aurora cluster read latency is too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.read_latency_alarm_evaluation_periods
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = var.read_latency_alarm_period
  statistic           = "Average"
  threshold           = var.read_latency_alarm_threshold
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = try(aws_rds_cluster.this[0].cluster_identifier, "")
  }

  tags = merge(local.tags, {
    Name = "${var.name}-aurora-read-latency"
  })
}

# Write Latency Alarm
module "aurora_write_latency_alarm" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  source  = "oozou/cloudwatch-alarm/aws"
  version = "1.0.0"

  prefix      = var.prefix
  environment = var.environment
  name        = "${var.name}-aurora-write-latency"

  alarm_description   = "Aurora cluster write latency is too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.write_latency_alarm_evaluation_periods
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = var.write_latency_alarm_period
  statistic           = "Average"
  threshold           = var.write_latency_alarm_threshold
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = try(aws_rds_cluster.this[0].cluster_identifier, "")
  }

  tags = merge(local.tags, {
    Name = "${var.name}-aurora-write-latency"
  })
}
