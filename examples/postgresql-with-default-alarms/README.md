# Aurora PostgreSQL with Default CloudWatch Alarms Example

This example demonstrates how to create an Aurora PostgreSQL cluster with default CloudWatch alarms enabled using the terraform-aws-aurora module.

## Features

This example creates:

- Aurora PostgreSQL cluster with 2 instances (writer and reader)
- VPC with public, private, and database subnets
- **Default CloudWatch alarms** automatically configured:
  - CPU utilization (80% threshold)
  - Database connections (80 connections threshold)
  - Freeable memory (100MB threshold, per instance)
  - Read latency (200ms threshold)
  - Write latency (200ms threshold)
- SNS topic for alarm notifications
- Email subscription for notifications
- Optional custom alarms in addition to defaults

## Default CloudWatch Alarms

When `is_enabled_default_alarm = true`, the following alarms are automatically created:

### Cluster-Level Alarms
- **CPU Utilization**: Threshold 80%, 2 evaluation periods, 5-minute intervals
- **Database Connections**: Threshold 80 connections, 2 evaluation periods, 5-minute intervals
- **Read Latency**: Threshold 0.2 seconds, 2 evaluation periods, 5-minute intervals
- **Write Latency**: Threshold 0.2 seconds, 2 evaluation periods, 5-minute intervals

### Instance-Level Alarms (Per Instance)
- **Freeable Memory**: Threshold 100MB, 2 evaluation periods, 5-minute intervals

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

## Configuration Options

### Enable Default Alarms Only
```hcl
module "aurora" {
  # ... other configuration ...

  # Enable default alarms
  is_enabled_default_alarm = true
  default_alarm_actions    = [aws_sns_topic.aurora_alarms.arn]
  default_ok_actions       = [aws_sns_topic.aurora_alarms.arn]
}
```

### Enable Default Alarms + Custom Alarms
```hcl
module "aurora" {
  # ... other configuration ...

  # Enable default alarms
  is_enabled_default_alarm = true
  default_alarm_actions    = [aws_sns_topic.aurora_alarms.arn]
  default_ok_actions       = [aws_sns_topic.aurora_alarms.arn]

  # Add custom alarms (merged with defaults)
  custom_aurora_cluster_alarms_configure = {
    custom_high_cpu = {
      metric_name         = "CPUUtilization"
      statistic           = "Average"
      comparison_operator = ">="
      threshold           = "90" # Higher threshold than default
      period              = "300"
      evaluation_periods  = "3"
      alarm_actions       = [aws_sns_topic.aurora_alarms.arn]
      ok_actions          = [aws_sns_topic.aurora_alarms.arn]
    }
  }

  custom_aurora_instance_alarms_configure = {
    custom_low_memory = {
      metric_name         = "FreeableMemory"
      statistic           = "Average"
      comparison_operator = "<="
      threshold           = "52428800" # 50MB threshold
      period              = "300"
      evaluation_periods  = "3"
      alarm_actions       = [aws_sns_topic.aurora_alarms.arn]
      ok_actions          = [aws_sns_topic.aurora_alarms.arn]
    }
  }
}
```

### Custom Alarms Only (No Defaults)
```hcl
module "aurora" {
  # ... other configuration ...

  # Disable default alarms
  is_enabled_default_alarm = false

  # Define only custom alarms
  custom_aurora_cluster_alarms_configure = {
    # Your custom cluster alarms
  }

  custom_aurora_instance_alarms_configure = {
    # Your custom instance alarms
  }
}
```

## Key Benefits

- **Zero Configuration**: Default alarms work out-of-the-box with sensible thresholds
- **Flexible**: Can combine default alarms with custom ones
- **Consistent**: Same alarm naming and structure across all deployments
- **PostgreSQL Optimized**: Configured specifically for Aurora PostgreSQL workloads

## Outputs

The example provides several outputs including:

- Aurora cluster information (ARN, ID, endpoints)
- All CloudWatch alarm ARNs (default + custom)
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
