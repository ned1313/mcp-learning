#!/usr/bin/env pwsh

# Script to check Terraform best practices

# Determine the repository root directory
$RepoRoot = git rev-parse --show-toplevel

# Set colors for output
$ErrorColor = "Red"
$WarningColor = "Yellow"
$SuccessColor = "Green"
$InfoColor = "Cyan"

Write-Host "Checking Terraform files for best practices..." -ForegroundColor $InfoColor

# Get all .tf files in the repository
$TerraformFiles = Get-ChildItem -Path $RepoRoot -Recurse -Filter "*.tf" | 
    Where-Object { 
        -not $_.FullName.Contains(".terraform") -and 
        -not $_.FullName.Contains(".terragrunt-cache")
    }

$IssuesFound = $false

# Check 1: Default tags variable
$HasTagsVariable = $false
foreach ($File in $TerraformFiles) {
    $Content = Get-Content -Path $File.FullName -Raw -ErrorAction SilentlyContinue
    if ($Content -match "variable\s+[""']tags[""']") {
        $HasTagsVariable = $true
        break
    }
}

if (-not $HasTagsVariable) {
    Write-Host "WARNING: Consider defining a 'tags' variable for consistent resource tagging" -ForegroundColor $WarningColor
    $IssuesFound = $true
}

# Check 2: Backend configuration
$HasBackendConfig = $false
foreach ($File in $TerraformFiles) {
    $Content = Get-Content -Path $File.FullName -Raw -ErrorAction SilentlyContinue
    if ($Content -match "backend\s+[""'][a-zA-Z0-9_-]+[""']\s*\{") {
        $HasBackendConfig = $true
        break
    }
}

if (-not $HasBackendConfig) {
    Write-Host "WARNING: No backend configuration found. Consider using a remote backend for state management" -ForegroundColor $WarningColor
    $IssuesFound = $true
}

# Check 3: Required version constraints
$HasVersionConstraints = $false
foreach ($File in $TerraformFiles) {
    $Content = Get-Content -Path $File.FullName -Raw -ErrorAction SilentlyContinue
    if ($Content -match "required_providers\s*\{") {
        $HasVersionConstraints = $true
        break
    }
}

if (-not $HasVersionConstraints) {
    Write-Host "WARNING: No provider version constraints found. Consider specifying provider versions for stability" -ForegroundColor $WarningColor
    $IssuesFound = $true
}

# Check 4: Resource names follow naming convention (example: lowercase with underscores)
$BadNamedResources = @()
foreach ($File in $TerraformFiles) {
    $Content = Get-Content -Path $File.FullName -Raw -ErrorAction SilentlyContinue
    $ResourceMatches = [regex]::Matches($Content, "resource\s+[""']([a-zA-Z0-9_-]+)[""']\s+[""']([a-zA-Z0-9_-]+)[""']")
    
    foreach ($Match in $ResourceMatches) {
        $ResourceName = $Match.Groups[2].Value
        # Check if resource name contains uppercase letters
        if ($ResourceName -cmatch "[A-Z]") {
            $BadNamedResources += @{
                File = $File.FullName.Replace($RepoRoot, "").TrimStart("\", "/")
                Name = $ResourceName
            }
        }
    }
}

if ($BadNamedResources.Count -gt 0) {
    Write-Host "WARNING: Found resources with uppercase letters in their names. Consider using lowercase with underscores:" -ForegroundColor $WarningColor
    foreach ($Resource in $BadNamedResources) {
        Write-Host "  - $($Resource.Name) in $($Resource.File)" -ForegroundColor $WarningColor
    }
    $IssuesFound = $true
}

# Check 5: Variables have descriptions
$VarsWithoutDesc = @()
foreach ($File in $TerraformFiles) {
    $Content = Get-Content -Path $File.FullName -Raw -ErrorAction SilentlyContinue
    $VarBlockMatches = [regex]::Matches($Content, "variable\s+[""']([a-zA-Z0-9_-]+)[""']\s*\{([^}]+)\}")
    
    foreach ($Match in $VarBlockMatches) {
        $VarName = $Match.Groups[1].Value
        $VarBlock = $Match.Groups[2].Value
        
        if (-not ($VarBlock -match "description\s*=")) {
            $VarsWithoutDesc += @{
                File = $File.FullName.Replace($RepoRoot, "").TrimStart("\", "/")
                Name = $VarName
            }
        }
    }
}

if ($VarsWithoutDesc.Count -gt 0) {
    Write-Host "WARNING: Found variables without description:" -ForegroundColor $WarningColor
    foreach ($Var in $VarsWithoutDesc) {
        Write-Host "  - $($Var.Name) in $($Var.File)" -ForegroundColor $WarningColor
    }
    $IssuesFound = $true
}

if ($IssuesFound) {
    Write-Host "Terraform best practices check found potential improvements." -ForegroundColor $WarningColor
    Write-Host "Review the warnings above to improve your Terraform code quality." -ForegroundColor $InfoColor
    exit 1 # Exit with error code for proper detection
} else {
    Write-Host "Terraform best practices check completed successfully. No issues found!" -ForegroundColor $SuccessColor
    exit 0 # Exit with success code
}
