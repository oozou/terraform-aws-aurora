provider "aws" {
  region = local.region
}

locals {
  name   = "postgresql"
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
# RDS Aurora Module
################################################################################

module "aurora" {
  source = "../.."

  name        = "serverless-demo-db"
  environment = "uat"
  engine_mode = "serverless"
  engine      = "aurora-postgresql"

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 16
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  vpc_id              = module.vpc.vpc_id
  db_subnet_group_ids = module.vpc.database_subnet_ids

  security_group_ingress_rules = {
    allow_all = {
      cidr_blocks = ["0.0.0.0/0"]
    }


  }
  security_group_egress_rules = {
    anywhere = {
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }

  is_storage_encrypted = true
  kms_key_id           = null

  # enabled_cloudwatch_logs_exports = # NOT SUPPORTED
  is_skip_final_snapshot          = true
  db_parameter_group_name         = aws_db_parameter_group.example.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example.id
  tags                            = { workspace = "000-oozou-aurora test" }
}

resource "aws_db_parameter_group" "example" {
  name        = "${local.name}-aurora-db-postgres10-parameter-group"
  family      = "aurora-postgresql10"
  description = "${local.name}-aurora-db-postgres10-parameter-group"
  tags        = local.tags
}

resource "aws_rds_cluster_parameter_group" "example" {
  name        = "${local.name}-aurora-postgres10-cluster-parameter-group"
  family      = "aurora-postgresql10"
  description = "${local.name}-aurora-postgres10-cluster-parameter-group"
  tags        = local.tags
}

