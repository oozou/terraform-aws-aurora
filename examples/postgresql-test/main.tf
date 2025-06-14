provider "aws" {
  region = var.aws_region
}

locals {
  name   = var.name
  region = var.aws_region
  tags = {
    Owner       = "terratest"
    Environment = var.environment
    TestSuite   = "postgresql-aurora-test"
  }
}

################################################################################
# Supporting Resources
################################################################################

resource "random_password" "master" {
  length = 16
}

################################################################################
# SNS Topic for Alarm Notifications (for testing)
################################################################################
resource "aws_sns_topic" "aurora_alarms" {
  name = "${local.name}-aurora-alarms"
  tags = local.tags
}

################################################################################
# VPC Configuration
################################################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = "10.99.0.0/18"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]

  create_database_subnet_group = true

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}

################################################################################
# KMS Key for RDS Encryption
################################################################################
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7

  tags = merge(local.tags, {
    Name = "${local.name}-rds-kms-key"
  })
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${local.name}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

################################################################################
# RDS Aurora PostgreSQL Module
################################################################################

module "aurora" {
  source = "../.."

  name        = local.name
  prefix      = "test"
  environment = var.environment

  engine         = "aurora-postgresql"
  engine_version = "15.4"

  is_instances_use_identifier_prefix = true
  instances = {
    writer = {
      identifier_prefix = "writer-db-instance"
      instance_class    = "db.t4g.medium"
    }
    reader = {
      identifier_prefix = "reader-db-instance"
      instance_class    = "db.t4g.medium"
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
  db_subnet_group_ids = module.vpc.database_subnets

  security_group_ingress_rules = {
    vpc_ingress = {
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "VPC ingress"
    }
  }

  security_group_egress_rules = {
    all_outbound = {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  }

  performance_insights_enabled = true

  # Encryption settings
  is_storage_encrypted = true
  kms_key_id          = aws_kms_key.rds.arn

  # Backup settings
  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"

  is_skip_final_snapshot          = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Parameter groups
  is_create_db_parameter_group         = true
  is_create_db_cluster_parameter_group = true

  db_parameters = [
    {
      name         = "log_statement"
      value        = "all"
      apply_method = "immediate"
    }
  ]

  db_cluster_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = "1000"
      apply_method = "immediate"
    }
  ]

  # Enable Default CloudWatch Alarms
  is_enabled_default_alarm = true
  default_alarm_actions    = [aws_sns_topic.aurora_alarms.arn]
  default_ok_actions       = [aws_sns_topic.aurora_alarms.arn]

  # Custom alarms for testing
  custom_aurora_cluster_alarms_configure = {
    custom_high_cpu = {
      metric_name         = "CPUUtilization"
      statistic           = "Average"
      comparison_operator = ">="
      threshold           = "90"
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
      threshold           = "104857600" # 100MB
      period              = "300"
      evaluation_periods  = "2"
      alarm_actions       = [aws_sns_topic.aurora_alarms.arn]
      ok_actions          = [aws_sns_topic.aurora_alarms.arn]
    }
  }

  tags = local.tags
}
