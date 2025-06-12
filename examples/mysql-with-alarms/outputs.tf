################################################################################
# Aurora Cluster Outputs
################################################################################
output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = module.aurora.cluster_arn
}

output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = module.aurora.cluster_id
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.aurora.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.aurora.cluster_reader_endpoint
}

################################################################################
# CloudWatch Alarms Outputs
################################################################################
output "aurora_cpu_alarm_arn" {
  description = "The ARN of the Aurora CPU utilization alarm"
  value       = module.aurora.aurora_cpu_alarm_arn
}

output "aurora_database_connections_alarm_arn" {
  description = "The ARN of the Aurora database connections alarm"
  value       = module.aurora.aurora_database_connections_alarm_arn
}

output "aurora_freeable_memory_alarm_arns" {
  description = "The ARNs of the Aurora freeable memory alarms"
  value       = module.aurora.aurora_freeable_memory_alarm_arns
}

output "aurora_read_latency_alarm_arn" {
  description = "The ARN of the Aurora read latency alarm"
  value       = module.aurora.aurora_read_latency_alarm_arn
}

output "aurora_write_latency_alarm_arn" {
  description = "The ARN of the Aurora write latency alarm"
  value       = module.aurora.aurora_write_latency_alarm_arn
}

################################################################################
# SNS Topic Output
################################################################################
output "sns_topic_arn" {
  description = "The ARN of the SNS topic for alarm notifications"
  value       = aws_sns_topic.aurora_alarms.arn
}
