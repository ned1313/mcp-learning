#!/usr/bin/env pwsh

# Script to check for sensitive information in the repository

# Determine the repository root directory
$RepoRoot = git rev-parse --show-toplevel

# Set colors for output
$ErrorColor = "Red"
$WarningColor = "Yellow"
$SuccessColor = "Green"
$InfoColor = "Cyan"

Write-Host "Checking for sensitive information in the codebase..." -ForegroundColor $InfoColor

# Define patterns to search for
$Patterns = @(
    @{
        Name = "AWS Access Key"
        Pattern = "(?i)AKIA[0-9A-Z]{16}"
        Description = "AWS Access Key"
    },
    @{
        Name = "AWS Secret Key"
        Pattern = "(?i)[0-9a-zA-Z/+]{40}"
        Description = "Potential AWS Secret Key"
    },
    @{
        Name = "Azure Storage Account Key"
        Pattern = "(?i)DefaultEndpointsProtocol=https;AccountName=.+;AccountKey=.+;EndpointSuffix="
        Description = "Azure Storage Account connection string"
    },
    @{
        Name = "Azure SAS Token"
        Pattern = "(?i)sig=[0-9a-zA-Z%]+&"
        Description = "Azure SAS Token"
    },
    @{
        Name = "Private Key"
        Pattern = "-----BEGIN PRIVATE KEY-----"
        Description = "Private Key found"
    },
    @{
        Name = "SSH Key"
        Pattern = "-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----"
        Description = "SSH Private Key found"
    },
    @{
        Name = "Password Assignment"
        Pattern = "(?i)(?:password|pwd|passwd|pass).*?[=:].+?"
        Description = "Potential password assignment"
    },
    @{
        Name = "GitHub Token"
        Pattern = "(?i)github_token|github_pat|gh_token"
        Description = "GitHub token"
    },
    @{
        Name = "API Key"
        Pattern = "(?i)api[_\-]?key.*?[=:].+?"
        Description = "Potential API key"
    }
)

# Files to exclude (adjust as needed)
$ExcludePatterns = @(
    ".git/",
    "*.md",
    "*.png",
    "*.jpg",
    "*.tfstate",
    "*.tfstate.backup",
    ".terraform/",
    ".terraform/*",                 # Files directly in .terraform
    "*/.terraform/*",               # Files in .terraform in subdirectories
    "**/.terraform/**",             # Any path containing .terraform
    "check-sensitive-info.ps1"      # Ignore this script itself
)

# Get all files from the repository
$Files = Get-ChildItem -Path $RepoRoot -Recurse -File | 
    Where-Object { 
        $FilePath = $_.FullName.Replace($RepoRoot, "").Replace("\", "/")
        
        # Explicit check for .terraform directory to ensure it's completely excluded
        if ($FilePath -like "*.terraform*" -or $FilePath -like ".terraform*") {
            return $false
        }
        
        # Explicitly exclude this script
        if ($_.Name -eq "check-sensitive-info.ps1") {
            return $false
        }
        
        $Exclude = $false
        foreach ($Pattern in $ExcludePatterns) {
            if ($FilePath -like $Pattern) {
                $Exclude = $true
                break
            }
        }
        -not $Exclude
    }

$IssuesFound = $false

foreach ($File in $Files) {
    $Content = Get-Content -Path $File.FullName -Raw -ErrorAction SilentlyContinue
    
    if ($null -eq $Content) {
        continue
    }
      foreach ($Pattern in $Patterns) {
        $RegexMatches = [regex]::Matches($Content, $Pattern.Pattern)
        
        if ($RegexMatches.Count -gt 0) {
            if (-not $IssuesFound) {
                $IssuesFound = $true
            }
            
            $RelativePath = $File.FullName.Replace($RepoRoot, "").TrimStart("\", "/")
            Write-Host "WARNING: $($Pattern.Description) found in $RelativePath" -ForegroundColor $WarningColor
        }
    }
}

if ($IssuesFound) {
    Write-Host "Sensitive information was found in the codebase. Please review and fix the issues above." -ForegroundColor $WarningColor
    Write-Host "For credentials and secrets, consider using environment variables, Azure Key Vault, or Terraform's encrypted backend." -ForegroundColor $InfoColor
    exit 1 # Exit with error code for proper detection
} else {
    Write-Host "No sensitive information found in the codebase." -ForegroundColor $SuccessColor
    exit 0 # Exit with success code
}
