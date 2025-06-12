/* -------------------------------------------------------------------------- */
/*                                  GENERICS                                  */
/* -------------------------------------------------------------------------- */
variable "prefix" {
  description = "The prefix name of customer to be displayed in AWS console and resource."
  type        = string
}

variable "name" {
  description = "Name used across resources created"
  type        = string
}

variable "environment" {
  description = "Environment name used as environment resources name."
  type        = string
}

variable "tags" {
  description = "Tags to add more; default tags contian {terraform=true, environment=var.environment}"
  type        = map(string)
  default     = {}
}

/* -------------------------------------------------------------------------- */
/*                                 RDS CLUSTER                                */
/* -------------------------------------------------------------------------- */
variable "is_create_db_subnet_group" {
  description = "Determines whether to create the databae subnet group or use existing"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "(optional) describe your variable"
  type        = list(string)
  default     = null
}

variable "db_subnet_group_name" {
  description = "The name of the subnet group name (existing or created)"
  type        = string
  default     = ""
}

variable "db_subnet_group_ids" {
  description = "List of subnet IDs used by database subnet group created"
  type        = list(string)
}

variable "is_create_cluster" {
  description = "Whether cluster should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "replication_source_identifier" {
  description = "ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica"
  type        = string
  default     = null
}

variable "engine" {
  description = "The name of the database engine to be used for this DB cluster. Valid Values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
  type        = string
}

variable "engine_mode" {
  description = "The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`. Defaults to: `provisioned`"
  type        = string
  default     = "provisioned"
}

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage"
  type        = string
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = null
}

variable "is_allow_major_version_upgrade" {
  description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to `false`"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying `kms_key_id`, `is_storage_encrypted` needs to be set to `true`"
  type        = string
  default     = null
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  default     = null
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "root"
}

variable "is_create_random_password" {
  description = "Determines whether to create random password for RDS primary cluster"
  type        = bool
  default     = true
}

variable "random_password_length" {
  description = "Length of random password to create. Defaults to `10`"
  type        = number
  default     = 10
}

variable "master_password" {
  description = "Password for the master DB user. Note - when specifying a value here, 'create_random_password' should be set to `false`"
  type        = string
  default     = ""
}

variable "is_skip_final_snapshot" {
  description = "Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false`"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Default `7`"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the `backup_retention_period` parameter. Time in UTC"
  type        = string
  default     = "20:00-21:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)"
  type        = string
  default     = "sat:22:00-sat:23:00"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate to the cluster in addition to the SG we create in this module"
  type        = list(string)
  default     = []
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot"
  type        = string
  default     = null
}

variable "is_storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted. The default is `true`"
  type        = bool
  default     = false
}

variable "is_apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is `false`"
  type        = bool
  default     = false
}

variable "db_cluster_db_instance_parameter_group_name" {
  description = "Instance parameter group to associate with all instances of the DB cluster. The `db_cluster_db_instance_parameter_group_name` is only valid in combination with `is_allow_major_version_upgrade`"
  type        = string
  default     = null
}

variable "is_iam_database_authentication_enabled" {
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  type        = bool
  default     = false
}

variable "is_copy_tags_to_snapshot" {
  description = "Copy all Cluster `tags` to snapshots"
  type        = bool
  default     = true
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql`. For this module support only `postgresql`"
  type        = list(string)
  default     = []
}

variable "restore_to_point_in_time" {
  description = "Map of nested attributes for cloning Aurora cluster"
  type        = map(string)
  default     = {}
}

variable "scaling_configuration" {
  description = "Map of nested attributes with scaling properties. Only valid when `engine_mode` is set to `serverless`"
  type        = map(string)
  default     = {}
}

/* -------------------------------------------------------------------------- */
/*                              CLUSTER INSTANCE                              */
/* -------------------------------------------------------------------------- */
variable "instances" {
  description = "Map of cluster instances and any specific/overriding attributes to be created"
  type        = any
  default     = {}
}

variable "is_instances_use_identifier_prefix" {
  description = "Determines whether cluster instance identifiers are used as prefixes"
  type        = bool
  default     = false
}

variable "instance_class" {
  description = "Instance type to use at master instance. Note: if `autoscaling_enabled` is `true`, this will be the same instance class used on instances created by autoscaling"
  type        = string
  default     = ""
}

variable "publicly_accessible" {
  description = "Determines whether instances are publicly accessible. Default false"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to `0` to disble. Default is `0`"
  type        = number
  default     = 0
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default `true`"
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not. Default `false`"
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years). Default to `7`"
  type        = number
  default     = 7
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

/* -------------------------------------------------------------------------- */
/*                              CLUSTER ENDPOINTS                             */
/* -------------------------------------------------------------------------- */
variable "endpoints" {
  description = "Map of additional cluster endpoints and their attributes to be created"
  type        = any
  default     = {}
}

/* -------------------------------------------------------------------------- */
/*                                IAM ROLE ASSO                               */
/* -------------------------------------------------------------------------- */
variable "iam_roles" {
  description = "Map of IAM roles and supported feature names to associate with the cluster"
  type        = map(map(string))
  default     = {}
}

/* -------------------------------------------------------------------------- */
/*                                 MONITORING                                 */
/* -------------------------------------------------------------------------- */
variable "is_create_monitoring_role" {
  description = "Determines whether to create the IAM role for RDS enhanced monitoring"
  type        = bool
  default     = true
}

variable "monitoring_role_arn" {
  description = "IAM role used by RDS to send enhanced monitoring metrics to CloudWatch"
  type        = string
  default     = ""
}

variable "iam_role_managed_policy_arns" {
  description = "Set of exclusive IAM managed policy ARNs to attach to the monitoring role"
  type        = list(string)
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any policies the monitoring role has before destroying it"
  type        = bool
  default     = null
}

variable "iam_role_max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the monitoring role"
  type        = number
  default     = null
}

/* -------------------------------------------------------------------------- */
/*                                AUTO SCALING                                */
/* -------------------------------------------------------------------------- */
variable "is_autoscaling_enabled" {
  description = "Determines whether autoscaling of the cluster read replicas is enabled"
  type        = bool
  default     = false
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 1
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 1
}

variable "predefined_metric_type" {
  description = "The metric type to scale on. Valid values are `RDSReaderAverageCPUUtilization` and `RDSReaderAverageDatabaseConnections`"
  type        = string
  default     = "RDSReaderAverageCPUUtilization"
}

variable "autoscaling_scale_in_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
  type        = number
  default     = 300
}

variable "autoscaling_scale_out_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
  type        = number
  default     = 300
}

variable "autoscaling_target_cpu" {
  description = "CPU threshold which will initiate autoscaling"
  type        = number
  default     = 70
}

variable "autoscaling_target_connections" {
  description = "Average number of connections threshold which will initiate autoscaling. Default value is 70% of db.r4/r5/r6g.large's default max_connections"
  type        = number
  default     = 700
}

/* -------------------------------------------------------------------------- */
/*                               SECURITY GROUP                               */
/* -------------------------------------------------------------------------- */
variable "is_create_security_group" {
  description = "Determines whether to create security group for RDS cluster"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "security_group_description" {
  description = "The description of the security group. If value is set to empty string it will contain cluster name in the description"
  type        = string
  default     = null
}

variable "security_group_ingress_rules" {
  description = "Map of ingress and any specific/overriding attributes to be created"
  type        = any
  default     = {}
}

variable "security_group_egress_rules" {
  description = "A map of security group egress rule defintions to add to the security group created"
  type        = any
  default     = {}
}

/* -------------------------------------------------------------------------- */
/*                               PARAMETER GROUP                              */
/* -------------------------------------------------------------------------- */
variable "is_create_db_parameter_group" {
  description = "Whether to create db parameter group or not"
  type        = bool
  default     = true
}

variable "db_parameter_group_name" {
  description = "Input existed name of the DB parameter group to associate with instances"
  type        = string
  default     = null
}

variable "db_parameters" {
  description = "A list of DB parameter maps to apply"
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default = []
}

variable "is_create_db_cluster_parameter_group" {
  description = "Whether to create db cluster parameter group or not"
  type        = bool
  default     = true
}

variable "db_cluster_parameter_group_name" {
  description = "Input existed cluster parameter group to associate with the cluster"
  type        = string
  default     = null
}

variable "db_cluster_parameters" {
  description = "A list of DB parameter maps to apply"
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default = []
}

/* -------------------------------------------------------------------------- */
/*                               CLOUD WATCH                                  */
/* -------------------------------------------------------------------------- */

variable "cloudwatch_log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire"
  type        = number
  default     = 90
}

variable "cloudwatch_log_kms_key_id" {
  description = "The ARN for the KMS encryption key."
  type        = string
  default     = null
}

/* -------------------------------------------------------------------------- */
/*                               CLOUDWATCH ALARMS                            */
/* -------------------------------------------------------------------------- */
variable "is_enabled_default_alarm" {
  description = "Whether to enable default CloudWatch alarms for Aurora cluster"
  type        = bool
  default     = false
}

variable "default_alarm_actions" {
  description = "List of ARN of the actions to execute when default alarms transition into an ALARM state"
  type        = list(string)
  default     = []
}

variable "default_ok_actions" {
  description = "List of ARN of the actions to execute when default alarms transition into an OK state"
  type        = list(string)
  default     = []
}

variable "custom_aurora_cluster_alarms_configure" {
  description = <<EOF
    Custom Aurora cluster alarms configuration. Example:
    custom_aurora_cluster_alarms_configure = {
      cpu_utilization_too_high = {
        metric_name         = "CPUUtilization"
        statistic           = "Average"
        comparison_operator = ">="
        threshold           = "85"
        period              = "300"
        evaluation_periods  = "1"
        alarm_actions       = [sns_topic_arn]
        ok_actions          = [sns_topic_arn]
      }
      database_connections_too_high = {
        metric_name         = "DatabaseConnections"
        statistic           = "Average"
        comparison_operator = ">="
        threshold           = "80"
        period              = "300"
        evaluation_periods  = "2"
        alarm_actions       = [sns_topic_arn]
        ok_actions          = [sns_topic_arn]
      }
      read_latency_too_high = {
        metric_name         = "ReadLatency"
        statistic           = "Average"
        comparison_operator = ">="
        threshold           = "0.2"
        period              = "300"
        evaluation_periods  = "2"
        alarm_actions       = [sns_topic_arn]
        ok_actions          = [sns_topic_arn]
      }
      write_latency_too_high = {
        metric_name         = "WriteLatency"
        statistic           = "Average"
        comparison_operator = ">="
        threshold           = "0.2"
        period              = "300"
        evaluation_periods  = "2"
        alarm_actions       = [sns_topic_arn]
        ok_actions          = [sns_topic_arn]
      }
    }
  EOF
  type        = any
  default     = {}
}

variable "custom_aurora_instance_alarms_configure" {
  description = <<EOF
    Custom Aurora instance alarms configuration. Example:
    custom_aurora_instance_alarms_configure = {
      freeable_memory_too_low = {
        metric_name         = "FreeableMemory"
        statistic           = "Average"
        comparison_operator = "<="
        threshold           = "104857600"
        period              = "300"
        evaluation_periods  = "2"
        alarm_actions       = [sns_topic_arn]
        ok_actions          = [sns_topic_arn]
      }
      cpu_utilization_too_high = {
        metric_name         = "CPUUtilization"
        statistic           = "Average"
        comparison_operator = ">="
        threshold           = "85"
        period              = "300"
        evaluation_periods  = "2"
        alarm_actions       = [sns_topic_arn]
        ok_actions          = [sns_topic_arn]
      }
    }
EOF
  type        = any
  default     = {}
}
