# Aurora MySQL with CloudWatch Alarms Example

This example demonstrates how to create an Aurora MySQL cluster with comprehensive CloudWatch alarms using the terraform-aws-aurora module.

## Features

This example creates:

- Aurora MySQL cluster with 2 instances (writer and reader)
- VPC with public, private, and database subnets
- CloudWatch alarms for monitoring:
  - CPU utilization
  - Database connections
  - Freeable memory (per instance)
  - Read latency
  - Write latency
- SNS topic for alarm notifications
- Email subscription for notifications

## CloudWatch Alarms

The following alarms are configured:

### CPU Utilization Alarm
- **Metric**: CPUUtilization
- **Threshold**: 75%
- **Evaluation Periods**: 2
- **Period**: 300 seconds (5 minutes)

### Database Connections Alarm
- **Metric**: DatabaseConnections
- **Threshold**: 100 connections
- **Evaluation Periods**: 2
- **Period**: 300 seconds (5 minutes)

### Freeable Memory Alarm (Per Instance)
- **Metric**: FreeableMemory
- **Threshold**: 100MB (104857600 bytes)
- **Evaluation Periods**: 2
- **Period**: 300 seconds (5 minutes)

### Read Latency Alarm
- **Metric**: ReadLatency
- **Threshold**: 0.2 seconds (200ms)
- **Evaluation Periods**: 2
- **Period**: 300 seconds (5 minutes)

### Write Latency Alarm
- **Metric**: WriteLatency
- **Threshold**: 0.2 seconds (200ms)
- **Evaluation Periods**: 2
- **Period**: 300 seconds (5 minutes)

## Usage

1. Update the email address in `main.tf`:
   ```hcl
   resource "aws_sns_topic_subscription" "email" {
     topic_arn = aws_sns_topic.aurora_alarms.arn
     protocol  = "email"
     endpoint  = "your-email@example.com" # Replace with your email
   }
   ```

2. Initialize and apply the Terraform configuration:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. Confirm the SNS subscription in your email inbox.

## Customization

You can customize the alarm thresholds and settings by modifying the variables in the module block:

```hcl
module "aurora" {
  # ... other configuration ...

  # CloudWatch Alarms Configuration
  enable_cloudwatch_alarms = true
  alarm_actions           = [aws_sns_topic.aurora_alarms.arn]
  ok_actions              = [aws_sns_topic.aurora_alarms.arn]

  # Customize thresholds
  cpu_alarm_threshold                   = 80  # Change CPU threshold to 80%
  connections_alarm_threshold           = 150 # Change connections threshold to 150
  memory_alarm_threshold               = 52428800 # Change memory threshold to 50MB
  read_latency_alarm_threshold         = 0.1  # Change read latency to 100ms
  write_latency_alarm_threshold        = 0.1  # Change write latency to 100ms
  
  # Customize evaluation periods
  cpu_alarm_evaluation_periods         = 3    # Require 3 consecutive periods
  connections_alarm_evaluation_periods = 3
  memory_alarm_evaluation_periods      = 3
  read_latency_alarm_evaluation_periods = 3
  write_latency_alarm_evaluation_periods = 3
}
```

## Outputs

The example provides several outputs including:

- Aurora cluster information (ARN, ID, endpoints)
- CloudWatch alarm ARNs
- SNS topic ARN

## Clean Up

To destroy the resources:

```bash
terraform destroy
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## External Module Used

This example uses the `oozou/cloudwatch-alarm/aws` module version `1.0.0` for creating CloudWatch alarms as specified in the requirements.
