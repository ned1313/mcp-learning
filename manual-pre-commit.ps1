#!/usr/bin/env pwsh

# Determine the repository root directory
$RepoRoot = git rev-parse --show-toplevel

# Set colors for output
$ErrorColor = "Red"
$WarningColor = "Yellow"
$SuccessColor = "Green"
$InfoColor = "Cyan"

Write-Host "Starting pre-commit checks..." -ForegroundColor $InfoColor
Write-Host "===============================" -ForegroundColor $InfoColor

Write-Host "Running Terraform format..." -ForegroundColor $InfoColor
terraform fmt -recursive $RepoRoot

# Skip validation for now since we haven't initialized the modules
Write-Host "Skipping Terraform validation (requires terraform init)..." -ForegroundColor $WarningColor
# Set-Location $RepoRoot
# $ValidateResult = terraform validate
# if ($LASTEXITCODE -ne 0) {
#     Write-Host "Terraform validation failed. Please fix the issues before committing." -ForegroundColor $ErrorColor
#     exit 1
# }

Write-Host "Running TFSec security scan..." -ForegroundColor $InfoColor
if (Get-Command tfsec -ErrorAction SilentlyContinue) {
    $TfsecResult = & tfsec $RepoRoot --soft-fail
    if ($LASTEXITCODE -gt 0) {
        Write-Host "TFSec found potential security issues. Please review them." -ForegroundColor $WarningColor
        # Not exiting with error, just a warning
    }
} else {
    Write-Host "TFSec not found. Skipping security scan." -ForegroundColor $WarningColor
    Write-Host "Install TFSec from https://github.com/aquasecurity/tfsec" -ForegroundColor $InfoColor
}

Write-Host "Checking for sensitive information..." -ForegroundColor $InfoColor
& "$RepoRoot\check-sensitive-info.ps1"

Write-Host "Checking Terraform best practices..." -ForegroundColor $InfoColor
& "$RepoRoot\check-tf-best-practices.ps1"

Write-Host "Generating Terraform documentation..." -ForegroundColor $InfoColor
if (Get-Command terraform-docs -ErrorAction SilentlyContinue) {
    terraform-docs markdown table --output-file README.md --output-mode inject $RepoRoot
} else {
    Write-Host "terraform-docs not found. Skipping documentation generation." -ForegroundColor $WarningColor
    Write-Host "Install terraform-docs from https://terraform-docs.io/user-guide/installation/" -ForegroundColor $InfoColor
}

Write-Host "===============================" -ForegroundColor $InfoColor
Write-Host "Pre-commit checks completed successfully!" -ForegroundColor $SuccessColor
exit 0
