variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "aurora-postgresql-test"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"
}
