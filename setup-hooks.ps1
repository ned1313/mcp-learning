#!/usr/bin/env pwsh

# Script to install pre-commit and required tools

# Function to check if a command exists
function Test-CommandExists {
    param (
        [string]$Command
    )
    
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

# Function to install a tool with the best available method
function Install-Tool {
    param (
        [string]$ToolName,
        [string]$ChocoPackage = $ToolName,
        [string]$ScoopPackage = $ToolName,
        [string]$ManualInstallUrl
    )
    
    Write-Host "Installing $ToolName..." -ForegroundColor Yellow
    
    if (Test-CommandExists "choco") {
        Write-Host "Using Chocolatey to install $ToolName" -ForegroundColor Cyan
        choco install $ChocoPackage -y
    }
    elseif (Test-CommandExists "scoop") {
        Write-Host "Using Scoop to install $ToolName" -ForegroundColor Cyan
        scoop install $ScoopPackage
    }
    elseif ($ToolName -eq "pre-commit" -and (Test-CommandExists "pip")) {
        Write-Host "Using pip to install pre-commit" -ForegroundColor Cyan
        pip install pre-commit
    }
    else {
        Write-Host "Could not find suitable package manager. Please install $ToolName manually from:" -ForegroundColor Yellow
        Write-Host $ManualInstallUrl -ForegroundColor Yellow
        return $false
    }
    
    return $true
}

# Check for package managers
$HasChocolatey = Test-CommandExists "choco"
$HasScoop = Test-CommandExists "scoop"
$HasPip = Test-CommandExists "pip"

if (-not ($HasChocolatey -or $HasScoop -or $HasPip)) {
    Write-Host "No suitable package manager found. We recommend installing either:" -ForegroundColor Yellow
    Write-Host "  - Chocolatey: https://chocolatey.org/install" -ForegroundColor Yellow
    Write-Host "  - Scoop: https://scoop.sh/" -ForegroundColor Yellow
    Write-Host "  - Python/pip: https://www.python.org/downloads/" -ForegroundColor Yellow
}

# Check for git
if (-not (Test-CommandExists "git")) {
    Write-Host "Git is required but not installed. Please install Git from https://git-scm.com/downloads" -ForegroundColor Red
    exit 1
}

# Check for Terraform
if (-not (Test-CommandExists "terraform")) {
    $Success = Install-Tool -ToolName "terraform" -ManualInstallUrl "https://developer.hashicorp.com/terraform/downloads"
    if (-not $Success -and -not (Test-CommandExists "terraform")) {
        Write-Host "Terraform is required but could not be installed automatically." -ForegroundColor Red
        Write-Host "Please install manually from https://developer.hashicorp.com/terraform/downloads" -ForegroundColor Yellow
    }
}
else {
    Write-Host "Terraform is already installed!" -ForegroundColor Green
}

# Check if pre-commit is installed, install if not
if (-not (Test-CommandExists "pre-commit")) {
    $Success = Install-Tool -ToolName "pre-commit" -ManualInstallUrl "https://pre-commit.com/#install"
    if (-not $Success -and -not (Test-CommandExists "pre-commit")) {
        Write-Host "Could not install pre-commit. Install manually with 'pip install pre-commit'" -ForegroundColor Red
    }
}
else {
    Write-Host "pre-commit is already installed!" -ForegroundColor Green
}

# Check if tfsec is installed, install if not
if (-not (Test-CommandExists "tfsec")) {
    $Success = Install-Tool -ToolName "tfsec" -ManualInstallUrl "https://github.com/aquasecurity/tfsec#installation"
    if (-not $Success -and -not (Test-CommandExists "tfsec")) {
        Write-Host "Could not install tfsec automatically." -ForegroundColor Yellow
        Write-Host "Manual installation instructions:" -ForegroundColor Yellow
        Write-Host "  - Download from: https://github.com/aquasecurity/tfsec/releases" -ForegroundColor Yellow
        Write-Host "  - Add to your PATH" -ForegroundColor Yellow
    }
}
else {
    Write-Host "tfsec is already installed!" -ForegroundColor Green
}

# Check if terraform-docs is installed, install if not
if (-not (Test-CommandExists "terraform-docs")) {
    $Success = Install-Tool -ToolName "terraform-docs" -ManualInstallUrl "https://terraform-docs.io/user-guide/installation/"
    if (-not $Success -and -not (Test-CommandExists "terraform-docs")) {
        Write-Host "Could not install terraform-docs automatically." -ForegroundColor Yellow
        Write-Host "Manual installation instructions:" -ForegroundColor Yellow
        Write-Host "  - Download from: https://github.com/terraform-docs/terraform-docs/releases" -ForegroundColor Yellow
        Write-Host "  - Add to your PATH" -ForegroundColor Yellow
    }
}
else {
    Write-Host "terraform-docs is already installed!" -ForegroundColor Green
}

# Check if markdownlint is installed (optional)
if (-not (Test-CommandExists "markdownlint")) {
    Write-Host "markdownlint is not installed (optional)." -ForegroundColor Yellow
    Write-Host "To install, you can use npm: npm install -g markdownlint-cli" -ForegroundColor Yellow
}
else {
    Write-Host "markdownlint is already installed!" -ForegroundColor Green
}

# Install the custom git hook
Write-Host "Setting up custom Git hooks..." -ForegroundColor Yellow
& "$PSScriptRoot\install-git-hook.ps1"

Write-Host "===============================" -ForegroundColor Cyan
Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host "The hooks will run automatically on git commit." -ForegroundColor Cyan
Write-Host "To run them manually, use: .\manual-pre-commit.ps1" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
