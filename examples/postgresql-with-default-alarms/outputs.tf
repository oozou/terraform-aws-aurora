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
output "aurora_cluster_alarms" {
  description = "Map of Aurora cluster alarms with their ARNs and IDs (includes default + custom)"
  value       = module.aurora.aurora_cluster_alarms
}

output "aurora_per_instance_alarms" {
  description = "Map of Aurora per-instance alarms with their ARNs and IDs (includes default + custom)"
  value       = module.aurora.aurora_per_instance_alarms
}

output "aurora_cluster_alarm_arns" {
  description = "Map of Aurora cluster alarm ARNs"
  value       = module.aurora.aurora_cluster_alarm_arns
}

output "aurora_per_instance_alarm_arns" {
  description = "Map of Aurora per-instance alarm ARNs"
  value       = module.aurora.aurora_per_instance_alarm_arns
}

################################################################################
# SNS Topic Output
################################################################################
output "sns_topic_arn" {
  description = "The ARN of the SNS topic for alarm notifications"
  value       = aws_sns_topic.aurora_alarms.arn
}
