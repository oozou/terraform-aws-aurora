output "db_subnet_group_name" {
  description = "The db subnet group name"
  value       = local.db_subnet_group_name
}

output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = try(aws_rds_cluster.this[0].arn, "")
}

output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = try(aws_rds_cluster.this[0].id, "")
}

output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = try(aws_rds_cluster.this[0].cluster_resource_id, "")
}

output "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = try(aws_rds_cluster.this[0].cluster_members, [])
  depends_on  = [aws_rds_cluster_instance.this]
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = try(aws_rds_cluster.this[0].endpoint, "")
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = try(aws_rds_cluster.this[0].reader_endpoint, "")
}

output "cluster_engine_version_actual" {
  description = "The running version of the cluster database"
  value       = try(aws_rds_cluster.this[0].engine_version_actual, "")
}

output "cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = var.database_name
}

output "cluster_port" {
  description = "The database port"
  value       = try(aws_rds_cluster.this[0].port, "")
}

output "cluster_master_password" {
  description = "The database master password"
  value       = try(aws_rds_cluster.this[0].master_password, "")
  sensitive   = true
}

output "cluster_master_username" {
  description = "The database master username"
  value       = try(aws_rds_cluster.this[0].master_username, "")
  sensitive   = true
}

output "cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint"
  value       = try(aws_rds_cluster.this[0].hosted_zone_id, "")
}

output "cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = aws_rds_cluster_instance.this
}

output "additional_cluster_endpoints" {
  description = "A map of additional cluster endpoints and their attributes"
  value       = aws_rds_cluster_endpoint.this
}

output "cluster_role_associations" {
  description = "A map of IAM roles associated with the cluster and their attributes"
  value       = aws_rds_cluster_role_association.this
}

output "enhanced_monitoring_iam_role_name" {
  description = "The name of the enhanced monitoring role"
  value       = try(aws_iam_role.rds_enhanced_monitoring[0].name, "")
}

output "enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
  value       = try(aws_iam_role.rds_enhanced_monitoring[0].arn, "")
}

output "enhanced_monitoring_iam_role_unique_id" {
  description = "Stable and unique string identifying the enhanced monitoring role"
  value       = try(aws_iam_role.rds_enhanced_monitoring[0].unique_id, "")
}

output "security_group_id" {
  description = "The security group ID of the cluster"
  value       = local.rds_security_group_id
}

output "client_security_group_id" {
  description = "The security group ID of the DB client"
  value       = local.rds_client_security_group_id
}

output "db_parameter_group_name" {
  description = "name of db parameter group"
  value       = join("", aws_db_parameter_group.this.*.id)
}

output "db_cluster_parameter_group_name" {
  description = "name of db cluster parameter group"
  value       = join("", aws_rds_cluster_parameter_group.this.*.id)
}

# CloudWatch Alarms Outputs
output "aurora_cluster_alarms" {
  description = "Map of Aurora cluster alarms with their ARNs and IDs"
  value = {
    for k, v in module.aurora_cluster_alarms : k => {
      arn = v.cloudwatch_metric_alarm_arn
      id  = v.cloudwatch_metric_alarm_id
    }
  }
}

output "aurora_per_instance_alarms" {
  description = "Map of Aurora per-instance alarms with their ARNs and IDs"
  value = {
    for k, v in module.aurora_per_instance_alarms : k => {
      arn = v.cloudwatch_metric_alarm_arn
      id  = v.cloudwatch_metric_alarm_id
    }
  }
}

output "aurora_cluster_alarm_arns" {
  description = "Map of Aurora cluster alarm ARNs"
  value       = { for k, v in module.aurora_cluster_alarms : k => v.cloudwatch_metric_alarm_arn }
}

output "aurora_cluster_alarm_ids" {
  description = "Map of Aurora cluster alarm IDs"
  value       = { for k, v in module.aurora_cluster_alarms : k => v.cloudwatch_metric_alarm_id }
}

output "aurora_per_instance_alarm_arns" {
  description = "Map of Aurora per-instance alarm ARNs"
  value       = { for k, v in module.aurora_per_instance_alarms : k => v.cloudwatch_metric_alarm_arn }
}

output "aurora_per_instance_alarm_ids" {
  description = "Map of Aurora per-instance alarm IDs"
  value       = { for k, v in module.aurora_per_instance_alarms : k => v.cloudwatch_metric_alarm_id }
}
