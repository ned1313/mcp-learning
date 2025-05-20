#!/usr/bin/env pwsh

# Script to install a simple pre-commit hook

# Get the repository root
$RepoRoot = git rev-parse --show-toplevel
$HookPath = Join-Path $RepoRoot ".git\hooks\pre-commit"

# Create the pre-commit hook content
$HookContent = @'
#!/bin/sh

# Path to the manual pre-commit script, relative to the repo root
SCRIPT_PATH="./manual-pre-commit.ps1"

# Get the repo root
REPO_ROOT=$(git rev-parse --show-toplevel)

# Run the PowerShell script
pwsh -File "$REPO_ROOT/$SCRIPT_PATH"

# Check the exit code
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "Pre-commit hook failed. Please fix the issues and try again."
  exit $exit_code
fi

exit 0
'@

# Save the hook script
Set-Content -Path $HookPath -Value $HookContent -Force
Write-Host "Pre-commit hook installed at $HookPath" -ForegroundColor Green

# Make the hook executable
if ($IsLinux -or $IsMacOS) {
    chmod +x $HookPath
    Write-Host "Made the hook executable" -ForegroundColor Green
}

Write-Host "Pre-commit hook setup complete!" -ForegroundColor Green
Write-Host "The hook will run automatically on git commit." -ForegroundColor Cyan
