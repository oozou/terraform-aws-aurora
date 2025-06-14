# Terraform AWS Aurora PostgreSQL Tests

This directory contains comprehensive tests for the terraform-aws-aurora module with PostgreSQL focus.

## Test Coverage

The test suite validates all 7 required scenarios:

✅ **DB Cluster Creation**: Tests Aurora PostgreSQL cluster creation with proper naming and endpoints  
✅ **Write/Read Instances**: Validates both writer and reader instances are created with correct roles  
✅ **KMS Encryption**: Verifies RDS storage encryption with custom KMS key  
✅ **Auto Backup**: Confirms backup retention (7 days) and window configuration (03:00-04:00)  
✅ **Custom Parameter Groups**: Tests creation of both DB and cluster parameter groups with proper apply_method  
✅ **Default CloudWatch Alarms**: Validates all 4 default alarms (CPU, connections, read/write latency)  
✅ **Security Groups**: Tests security group creation and proper VPC attachment  

## Test Reports

After running tests, comprehensive reports are automatically generated:

### 📊 Console Report
Displays a detailed summary in the terminal with:
- Test execution statistics (pass/fail/skip counts)
- Individual test results with duration
- Pass rate percentage
- Summary and recommendations

### 📄 JSON Report (`test-report.json`)
Machine-readable test results including:
- Detailed test metadata
- Execution timestamps and durations
- Individual test outcomes and error details
- Statistical summary

### 🌐 HTML Report (`test-report.html`)
Interactive web-based report featuring:
- Visual dashboard with statistics
- Color-coded test results
- Progress bars and charts
- Professional styling for presentations

## Usage

### Basic Test Execution
```bash
# Run all tests
cd tests && make test

# Run with verbose output
make test-verbose

# Run specific test
make test-specific TEST=TestDBClusterCreated
```

### Test Reports
```bash
# View available reports
make generate-report

# Open HTML report in browser
make open-report

# Run tests with coverage
make test-coverage
```

### Individual Test Categories
```bash
# Test cluster creation only
make test-cluster

# Test encryption only
make test-encryption

# Test backup configuration
make test-backup

# Test parameter groups
make test-params

# Test CloudWatch alarms
make test-alarms

# Test security groups
make test-security
```

## Test Configuration: `examples/postgresql-test/`

The test uses a dedicated Terraform configuration in the `examples/postgresql-test/` directory that includes:

- **VPC Setup**: Creates a test VPC with public, private, and database subnets
- **KMS Key**: Creates a dedicated KMS key for RDS encryption
- **Aurora Configuration**: Configures Aurora PostgreSQL 15.4 with all required features
- **CloudWatch Alarms**: Enables default alarms with SNS notifications
- **Parameter Groups**: Creates custom DB and cluster parameter groups with proper apply_method settings

## Sample Test Report Output

```
🧪 TERRAFORM AWS AURORA POSTGRESQL TEST REPORT
📅 Test Suite: Terraform AWS Aurora PostgreSQL Tests
⏰ Start Time: 2025-06-13 15:30:00 +07
⏰ End Time:   2025-06-13 16:15:00 +07
⏱️  Duration:   45m0s

--------------------------------------------------------------------------------
📊 TEST STATISTICS
--------------------------------------------------------------------------------
📈 Total Tests:   7
✅ Passed Tests:  7
❌ Failed Tests:  0
⏭️  Skipped Tests: 0
📊 Pass Rate:     100.0%

--------------------------------------------------------------------------------
📋 DETAILED TEST RESULTS
--------------------------------------------------------------------------------
1. TestDBClusterCreated - ✅ PASS (2m30s)
2. TestDBInstancesCreated - ✅ PASS (1m45s)
3. TestEncryptionEnabled - ✅ PASS (30s)
4. TestAutoBackupEnabled - ✅ PASS (15s)
5. TestCustomParameterGroupCreated - ✅ PASS (45s)
6. TestDefaultAlarmsCreated - ✅ PASS (1m15s)
7. TestSecurityGroupCreated - ✅ PASS (20s)

--------------------------------------------------------------------------------
📝 SUMMARY
--------------------------------------------------------------------------------
✅ ALL TESTS PASSED! 7/7 tests successful

🎉 Congratulations! All PostgreSQL Aurora tests passed successfully!
✅ Your terraform-aws-aurora module is working correctly for PostgreSQL.
```

## Requirements

- **Go**: 1.19 or later
- **Terraform**: 1.0 or later
- **AWS CLI**: Configured with appropriate credentials
- **AWS Permissions**: Full access to RDS, VPC, KMS, CloudWatch, SNS

## Cost Considerations

- **Estimated Cost**: $2-5 per test run
- **Duration**: ~45 minutes for full test suite
- **Resources**: Aurora cluster with 2 instances (t4g.medium)
- **Cleanup**: Automatic resource cleanup after tests

## Troubleshooting

### Common Issues

1. **Timeout Errors**: Increase timeout in Makefile if needed
2. **Permission Errors**: Ensure AWS credentials have required permissions
3. **Resource Limits**: Check AWS service limits for your region
4. **Network Issues**: Verify VPC and subnet configurations

### Debug Commands
```bash
# Validate Terraform configuration
make validate

# Plan Terraform deployment
make plan

# Show test configuration
make show-config

# Clean up resources manually
make clean
```
