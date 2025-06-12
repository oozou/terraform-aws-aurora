provider "aws" {
  region = local.region
}

locals {
  name   = "aurora-mysql-db-with-alarms"
  region = "ap-southeast-1"
  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

################################################################################
# Supporting Resources
################################################################################

resource "random_password" "master" {
  length = 10
}

################################################################################
# SNS Topic for Alarm Notifications
################################################################################
resource "aws_sns_topic" "aurora_alarms" {
  name = "${local.name}-aurora-alarms"
  tags = local.tags
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.aurora_alarms.arn
  protocol  = "email"
  endpoint  = "admin@example.com" # Replace with your email
}

################################################################################
# vpc
################################################################################
module "vpc" {
  source = "git@github.com:oozou/terraform-aws-vpc.git?ref=v1.1.2"

  is_create_vpc = true

  prefix       = "oozou"
  environment  = "test"
  account_mode = "spoke"

  cidr              = "10.105.0.0/16"
  public_subnets    = ["10.105.0.0/24", "10.105.1.0/24", "10.105.2.0/24"]
  private_subnets   = ["10.105.60.0/22", "10.105.64.0/22", "10.105.68.0/22"]
  database_subnets  = ["10.105.20.0/23", "10.105.22.0/23", "10.105.24.0/23"]
  availability_zone = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

  is_create_nat_gateway             = true
  is_enable_single_nat_gateway      = true
  is_create_flow_log                = false
  is_enable_flow_log_s3_integration = false

  tags = { workspace = "000-oozou-aurora test" }
}

################################################################################
# RDS Aurora Module with CloudWatch Alarms
################################################################################

module "aurora" {
  source = "../.."

  name        = local.name
  prefix      = "oozou"
  environment = "test"

  engine         = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.10.2"

  is_instances_use_identifier_prefix = true
  instances = {
    one = {
      identifier_prefix = "writer-db-instance1"
      instance_class    = "db.r4.large"
    }
    two = {
      identifier_prefix = "reader-db-instance1"
      instance_class    = "db.r4.large"
    }
  }
  endpoints = {
    reader = {
      identifier = "reader"
      type       = "READER"
    }
  }

  is_autoscaling_enabled   = true
  autoscaling_max_capacity = 3
  autoscaling_min_capacity = 1

  vpc_id              = module.vpc.vpc_id
  db_subnet_group_ids = module.vpc.database_subnet_ids

  security_group_ingress_rules = {
    allow_all = {
      cidr_blocks = ["0.0.0.0/0", "1.1.1.1/32"]
    }
    allow_vpn_in_client_network = {
      cidr_blocks = ["172.16.0.0/24"]
    }
  }
  security_group_egress_rules = {
    anywhere = {
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  performance_insights_enabled = true

  is_storage_encrypted = true
  kms_key_id           = null

  is_skip_final_snapshot          = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  db_parameter_group_name         = aws_db_parameter_group.example.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example.id

  # CloudWatch Alarms Configuration
  custom_aurora_cluster_alarms_configure = {
    cpu_utilization_too_high = {
      metric_name         = "CPUUtilization"
      statistic           = "Average"
      comparison_operator = ">="
      threshold           = "75"
      period              = "300"
      evaluation_periods  = "2"
      alarm_actions       = [aws_sns_topic.aurora_alarms.arn]
      ok_actions          = [aws_sns_topic.aurora_alarms.arn]
    }
    database_connections_too_high = {
      metric_name         = "DatabaseConnections"
      statistic           = "Average"
      comparison_operator = ">="
      threshold           = "100"
      period              = "300"
      evaluation_periods  = "2"
      alarm_actions       = [aws_sns_topic.aurora_alarms.arn]
      ok_actions          = [aws_sns_topic.aurora_alarms.arn]
    }
    read_latency_too_high = {
      metric_name         = "ReadLatency"
      statistic           = "Average"
      comparison_operator = ">="
      threshold           = "0.2"
      period              = "300"
      evaluation_periods  = "2"
      alarm_actions       = [aws_sns_topic.aurora_alarms.arn]
      ok_actions          = [aws_sns_topic.aurora_alarms.arn]
    }
    write_latency_too_high = {
      metric_name         = "WriteLatency"
      statistic           = "Average"
      comparison_operator = ">="
      threshold           = "0.2"
      period              = "300"
      evaluation_periods  = "2"
      alarm_actions       = [aws_sns_topic.aurora_alarms.arn]
      ok_actions          = [aws_sns_topic.aurora_alarms.arn]
    }
  }

  custom_aurora_instance_alarms_configure = {
    freeable_memory_too_low = {
      metric_name         = "FreeableMemory"
      statistic           = "Average"
      comparison_operator = "<="
      threshold           = "104857600"
      period              = "300"
      evaluation_periods  = "2"
      alarm_actions       = [aws_sns_topic.aurora_alarms.arn]
      ok_actions          = [aws_sns_topic.aurora_alarms.arn]
    }
  }

  tags = { workspace = "000-oozou-aurora test" }
}

resource "aws_db_parameter_group" "example" {
  name        = "${local.name}-aurora-db-57-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.name}-aurora-db-57-parameter-group"
  tags        = local.tags
}

resource "aws_rds_cluster_parameter_group" "example" {
  name        = "${local.name}-aurora-57-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.name}-aurora-57-cluster-parameter-group"
  tags        = local.tags
}
