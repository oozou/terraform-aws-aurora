# Change Log

All notable changes to this module will be documented in this file.

## [1.1.0] - 2025-05-23

### Added client security group

- add resources:
    - aws_security_group_rule.from_client
    - aws_security_group.client
    - aws_security_group_rule.to_cluster
- add output:
    - client_security_group_id

## [1.0.3] - 2022-10-07

### Added

- support create log group by terraform

## [1.0.2] - 2022-05-18

### Updated

- fix: resources naming and add compatible for create parameter

## [1.0.1] - 2022-04-29

### Added

- add support for mysql and serverless

## [1.0.0] - 2022-04-25

### Added

- init terraform-aws-aurora
