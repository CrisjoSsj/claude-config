# UPDATE.ps1 — pulls latest from origin and re-runs INSTALL.

$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

Set-Location $RepoDir

Write-Host ""
Write-Host "🔄 Updating claude-config from origin..."
Write-Host ""

git pull --ff-only origin main

& "$RepoDir\INSTALL.ps1"
