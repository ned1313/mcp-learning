#!/usr/bin/env pwsh

# Script to run all checks and prepare for a clean commit

param(
    [switch]$SkipFormat = $false,
    [switch]$SkipSecurity = $false,
    [switch]$SkipDocs = $false,
    [switch]$SkipBestPractices = $false,
    [switch]$SkipSensitiveCheck = $false
)

# Set colors for output
$ErrorColor = "Red"
$WarningColor = "Yellow"
$SuccessColor = "Green"
$InfoColor = "Cyan"

# Get repo root
$RepoRoot = git rev-parse --show-toplevel
Set-Location $RepoRoot

Write-Host "==============================================" -ForegroundColor $InfoColor
Write-Host "     Terraform Project Quality Checker" -ForegroundColor $InfoColor
Write-Host "==============================================" -ForegroundColor $InfoColor

$SuccessCount = 0
$WarningCount = 0
$ErrorCount = 0

# Step 1: Format code
if (-not $SkipFormat) {
    Write-Host "`n[1/5] Formatting Terraform code..." -ForegroundColor $InfoColor
    try {
        terraform fmt -recursive $RepoRoot
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Code formatting successful" -ForegroundColor $SuccessColor
            $SuccessCount++
        } else {
            Write-Host "✗ Code formatting failed" -ForegroundColor $ErrorColor
            $ErrorCount++
        }
    } catch {
        Write-Host "✗ Error running terraform fmt: $_" -ForegroundColor $ErrorColor
        $ErrorCount++
    }
} else {
    Write-Host "`n[1/5] Skipping code formatting" -ForegroundColor $WarningColor
}

# Step 2: Check for sensitive information
if (-not $SkipSensitiveCheck) {
    Write-Host "`n[2/5] Checking for sensitive information..." -ForegroundColor $InfoColor
    $sensitiveIssuesFound = $false
    
    # Run the sensitive info script and capture its output
    & "$RepoRoot\check-sensitive-info.ps1"
    
    # Check the exit code of the last command
    if ($LASTEXITCODE -eq 0) {
        $SuccessCount++
    } else {
        $WarningCount++
        $sensitiveIssuesFound = $true
    }
} else {
    Write-Host "`n[2/5] Skipping sensitive information check" -ForegroundColor $WarningColor
}

# Step 3: Check security with tfsec
if (-not $SkipSecurity) {
    Write-Host "`n[3/5] Running security scan with tfsec..." -ForegroundColor $InfoColor
    if (Get-Command tfsec -ErrorAction SilentlyContinue) {
        try {
            # Run tfsec and capture its output
            tfsec $RepoRoot --soft-fail --tfvars-file "$RepoRoot\terraform.tfvars"
            
            # Check if there were any security issues
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Security scan completed with no issues" -ForegroundColor $SuccessColor
                $SuccessCount++
            } else {
                Write-Host "! Security scan completed with warnings" -ForegroundColor $WarningColor
                $WarningCount++
            }
        } catch {
            Write-Host "✗ Error running tfsec: $_" -ForegroundColor $ErrorColor
            $ErrorCount++
        }
    } else {
        Write-Host "✗ tfsec not found. Install from https://github.com/aquasecurity/tfsec" -ForegroundColor $WarningColor
        $WarningCount++
    }
} else {
    Write-Host "`n[3/5] Skipping security scan" -ForegroundColor $WarningColor
}

# Step 4: Best practices check
if (-not $SkipBestPractices) {
    Write-Host "`n[4/5] Checking Terraform best practices..." -ForegroundColor $InfoColor
    $bestPracticesIssuesFound = $false
    
    # Run best practices script and capture output
    & "$RepoRoot\check-tf-best-practices.ps1"
    
    # Check the result of the best practices check
    if ($LASTEXITCODE -eq 0) {
        $SuccessCount++
    } else {
        $WarningCount++
        $bestPracticesIssuesFound = $true
    }
} else {
    Write-Host "`n[4/5] Skipping best practices check" -ForegroundColor $WarningColor
}

# Step 5: Generate documentation
if (-not $SkipDocs) {
    Write-Host "`n[5/5] Generating Terraform documentation..." -ForegroundColor $InfoColor
    if (Get-Command terraform-docs -ErrorAction SilentlyContinue) {
        try {
            terraform-docs markdown table --output-file README.md --output-mode inject $RepoRoot
            Write-Host "✓ Documentation generated successfully" -ForegroundColor $SuccessColor
            $SuccessCount++
        } catch {
            Write-Host "✗ Error generating documentation: $_" -ForegroundColor $ErrorColor
            $ErrorCount++
        }
    } else {
        Write-Host "✗ terraform-docs not found. Install from https://terraform-docs.io" -ForegroundColor $WarningColor
        $WarningCount++
    }
} else {
    Write-Host "`n[5/5] Skipping documentation generation" -ForegroundColor $WarningColor
}

# Summary
Write-Host "`n==============================================" -ForegroundColor $InfoColor
Write-Host "                 Summary" -ForegroundColor $InfoColor
Write-Host "==============================================" -ForegroundColor $InfoColor
Write-Host "Successes: $SuccessCount" -ForegroundColor $SuccessColor
Write-Host "Warnings: $WarningCount" -ForegroundColor $WarningColor
Write-Host "Errors: $ErrorCount" -ForegroundColor $ErrorColor
Write-Host "`nRun with parameters to skip steps:" -ForegroundColor $InfoColor
Write-Host "  -SkipFormat          Skip code formatting" -ForegroundColor $InfoColor
Write-Host "  -SkipSensitiveCheck  Skip sensitive information checks" -ForegroundColor $InfoColor
Write-Host "  -SkipSecurity        Skip security scanning" -ForegroundColor $InfoColor
Write-Host "  -SkipBestPractices   Skip best practices check" -ForegroundColor $InfoColor
Write-Host "  -SkipDocs            Skip documentation generation" -ForegroundColor $InfoColor
Write-Host "==============================================" -ForegroundColor $InfoColor

if ($ErrorCount -gt 0) {
    Write-Host "Checks completed with errors. Please fix the issues before committing." -ForegroundColor $ErrorColor
    exit 1
} elseif ($WarningCount -gt 0) {
    Write-Host "Checks completed with warnings. Please review warnings before committing." -ForegroundColor $WarningColor
    exit 0
} else {
    Write-Host "All checks passed successfully!" -ForegroundColor $SuccessColor
    exit 0
}
