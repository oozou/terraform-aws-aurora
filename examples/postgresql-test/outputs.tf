################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = module.aurora.cluster_arn
}

output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = module.aurora.cluster_id
}

output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = module.aurora.cluster_resource_id
}

output "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = module.aurora.cluster_members
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.aurora.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.aurora.cluster_reader_endpoint
}

output "cluster_engine_version_actual" {
  description = "The running version of the cluster database"
  value       = module.aurora.cluster_engine_version_actual
}

output "cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = module.aurora.cluster_database_name
}

output "cluster_port" {
  description = "The database port"
  value       = module.aurora.cluster_port
}

output "cluster_master_password" {
  description = "The database master password"
  value       = module.aurora.cluster_master_password
  sensitive   = true
}

output "cluster_master_username" {
  description = "The database master username"
  value       = module.aurora.cluster_master_username
  sensitive   = true
}

output "cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint"
  value       = module.aurora.cluster_hosted_zone_id
}

################################################################################
# Cluster Instance(s)
################################################################################

output "cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = module.aurora.cluster_instances
}

output "additional_cluster_endpoints" {
  description = "A map of additional cluster endpoints and their attributes"
  value       = module.aurora.additional_cluster_endpoints
}

################################################################################
# Cluster IAM Roles
################################################################################

output "cluster_role_associations" {
  description = "A map of IAM roles associated with the cluster and their attributes"
  value       = module.aurora.cluster_role_associations
}

################################################################################
# Enhanced Monitoring
################################################################################

output "enhanced_monitoring_iam_role_name" {
  description = "The name of the enhanced monitoring role"
  value       = module.aurora.enhanced_monitoring_iam_role_name
}

output "enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
  value       = module.aurora.enhanced_monitoring_iam_role_arn
}

output "enhanced_monitoring_iam_role_unique_id" {
  description = "Stable and unique string identifying the enhanced monitoring role"
  value       = module.aurora.enhanced_monitoring_iam_role_unique_id
}

################################################################################
# Security Group
################################################################################

output "security_group_id" {
  description = "The security group ID of the cluster"
  value       = module.aurora.security_group_id
}

output "client_security_group_id" {
  description = "The security group ID of the DB client"
  value       = module.aurora.client_security_group_id
}

################################################################################
# Parameter Groups
################################################################################

output "db_parameter_group_name" {
  description = "Name of db parameter group"
  value       = module.aurora.db_parameter_group_name
}

output "db_cluster_parameter_group_name" {
  description = "Name of db cluster parameter group"
  value       = module.aurora.db_cluster_parameter_group_name
}

################################################################################
# CloudWatch Alarms
################################################################################

output "aurora_cluster_alarms" {
  description = "Map of Aurora cluster alarms with their ARNs and IDs"
  value       = module.aurora.aurora_cluster_alarms
}

output "aurora_per_instance_alarms" {
  description = "Map of Aurora per-instance alarms with their ARNs and IDs"
  value       = module.aurora.aurora_per_instance_alarms
}

output "aurora_cluster_alarm_arns" {
  description = "Map of Aurora cluster alarm ARNs"
  value       = module.aurora.aurora_cluster_alarm_arns
}

output "aurora_cluster_alarm_ids" {
  description = "Map of Aurora cluster alarm IDs"
  value       = module.aurora.aurora_cluster_alarm_ids
}

output "aurora_per_instance_alarm_arns" {
  description = "Map of Aurora per-instance alarm ARNs"
  value       = module.aurora.aurora_per_instance_alarm_arns
}

output "aurora_per_instance_alarm_ids" {
  description = "Map of Aurora per-instance alarm IDs"
  value       = module.aurora.aurora_per_instance_alarm_ids
}

################################################################################
# Supporting Resources
################################################################################

output "vpc_id" {
  description = "ID of the VPC where resources are created"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = module.vpc.database_subnet_group
}

output "kms_key_id" {
  description = "The globally unique identifier for the KMS key"
  value       = aws_kms_key.rds.key_id
}

output "kms_key_arn" {
  description = "The Amazon Resource Name (ARN) of the KMS key"
  value       = aws_kms_key.rds.arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for alarm notifications"
  value       = aws_sns_topic.aurora_alarms.arn
}
