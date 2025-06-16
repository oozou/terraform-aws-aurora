.PHONY: help test test-verbose test-specific clean deps fmt lint

# Default target
help:
	@echo "Available targets:"
	@echo "  deps          - Download Go dependencies"
	@echo "  test          - Run all tests"
	@echo "  test-verbose  - Run all tests with verbose output"
	@echo "  test-specific - Run specific test (use TEST=TestName)"
	@echo "  clean         - Clean up test resources"
	@echo "  fmt           - Format Go code"
	@echo "  lint          - Run Go linter"
	@echo "  generate-report - Show available test reports"
	@echo "  open-report   - Open HTML test report in browser"
	@echo ""
	@echo "Examples:"
	@echo "  make test"
	@echo "  make test-specific TEST=TestDBClusterCreated"
	@echo "  make clean"
	@echo "  make open-report"

# Download dependencies
deps:
	@echo "Downloading Go dependencies..."
	go mod download
	go mod tidy

# Run all tests
test:
	@echo "Running all PostgreSQL Aurora tests..."
	go test -timeout 45m

# Run tests with verbose output
test-verbose:
	@echo "Running all PostgreSQL Aurora tests (verbose)..."
	go test -v -timeout 45m

# Run specific test
test-specific:
	@if [ -z "$(TEST)" ]; then \
		echo "Please specify TEST variable. Example: make test-specific TEST=TestDBClusterCreated"; \
		exit 1; \
	fi
	@echo "Running specific test: $(TEST)..."
	go test -v -timeout 45m -run $(TEST)

# Run tests for cluster creation only
test-cluster:
	@echo "Running cluster creation tests..."
	go test -v -timeout 45m -run TestDBClusterCreated

# Run tests for instances creation only
test-instances:
	@echo "Running instances creation tests..."
	go test -v -timeout 45m -run TestDBInstancesCreated

# Run tests for encryption only
test-encryption:
	@echo "Running encryption tests..."
	go test -v -timeout 45m -run TestEncryptionEnabled

# Run tests for backup only
test-backup:
	@echo "Running backup tests..."
	go test -v -timeout 45m -run TestAutoBackupEnabled

# Run tests for parameter groups only
test-params:
	@echo "Running parameter group tests..."
	go test -v -timeout 45m -run TestCustomParameterGroupCreated

# Run tests for alarms only
test-alarms:
	@echo "Running alarm tests..."
	go test -v -timeout 45m -run TestDefaultAlarmsCreated

# Run tests for security groups only
test-security:
	@echo "Running security group tests..."
	go test -v -timeout 45m -run TestSecurityGroupCreated

# Clean up any leftover test resources
clean:
	@echo "Cleaning up test resources..."
	@cd ../examples/postgresql-test && \
	if [ -f terraform.tfstate ]; then \
		echo "Found terraform state, running destroy..."; \
		terraform destroy -auto-approve || true; \
	else \
		echo "No terraform state found, nothing to clean"; \
	fi
	@echo "Cleaning up test reports..."
	@rm -f test-report.json test-report.html coverage.out coverage.html

# Format Go code
fmt:
	@echo "Formatting Go code..."
	go fmt ./...

# Run Go linter (requires golangci-lint to be installed)
lint:
	@echo "Running Go linter..."
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not found. Install it with:"; \
		echo "  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; \
	fi

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	go test -v -timeout 45m -coverprofile=coverage.out
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"
	@echo "Test report generated: test-report.html"

# Generate test report only (without running tests)
generate-report:
	@echo "Test reports available:"
	@if [ -f test-report.json ]; then echo "  📄 JSON Report: test-report.json"; fi
	@if [ -f test-report.html ]; then echo "  🌐 HTML Report: test-report.html"; fi
	@if [ -f coverage.html ]; then echo "  📊 Coverage Report: coverage.html"; fi

# Open test report in browser
open-report:
	@if [ -f test-report.html ]; then \
		echo "Opening test report in browser..."; \
		open test-report.html || xdg-open test-report.html || echo "Please open test-report.html manually"; \
	else \
		echo "No test report found. Run 'make test' first."; \
	fi

# Run tests in parallel
test-parallel:
	@echo "Running tests in parallel..."
	go test -v -timeout 45m -parallel 4

# Validate Terraform configuration
validate:
	@echo "Validating Terraform configuration..."
	@cd ../examples/postgresql-test && \
	terraform init -backend=false && \
	terraform validate

# Plan Terraform configuration (for debugging)
plan:
	@echo "Planning Terraform configuration..."
	@cd ../examples/postgresql-test && \
	terraform init && \
	terraform plan

# Show test configuration
show-config:
	@echo "Test Configuration:"
	@echo "  Go version: $$(go version)"
	@echo "  Terraform version: $$(terraform version | head -n1)"
	@echo "  AWS CLI version: $$(aws --version 2>/dev/null || echo 'AWS CLI not found')"
	@echo "  Current AWS region: $$(aws configure get region 2>/dev/null || echo 'Not configured')"
	@echo "  Test timeout: 45 minutes"

# Install required tools
install-tools:
	@echo "Installing required tools..."
	@echo "Installing golangci-lint..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@echo "Tools installed successfully"

# Run all checks (format, lint, validate, test)
check-all: fmt lint validate test
	@echo "All checks completed successfully!"
	@echo "📊 Test reports generated:"
	@make generate-report
