# INSTALL.ps1 — installer Windows PowerShell para claude-config
#
# Comentario en español: instala el setup en %USERPROFILE%\.claude\, hace backup
# automático, verifica que todo cargó bien, e imprime versión instalada.

$ErrorActionPreference = "Stop"

$RepoDir   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SourceDir = Join-Path $RepoDir "claude-config"
$TargetDir = Join-Path $env:USERPROFILE ".claude"
$Stamp     = Get-Date -Format "yyyy-MM-dd-HHmmss"
$BackupDir = Join-Path $env:USERPROFILE ".claude.backup.$Stamp"
$Version   = if (Test-Path "$RepoDir\VERSION") { Get-Content "$RepoDir\VERSION" -Raw } else { "unknown" }
$Version   = $Version.Trim()

function Log    { param($msg) Write-Host "  $msg" }
function OK     { param($msg) Write-Host "  ✅ $msg" -ForegroundColor Green }
function WarnMsg{ param($msg) Write-Host "  ⚠️  $msg" -ForegroundColor Yellow }
function ErrMsg { param($msg) Write-Host "  ❌ $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "🔧 Installing claude-config v$Version"
Write-Host ""

if (-not (Test-Path $SourceDir)) {
    ErrMsg "Source dir not found: $SourceDir"
    exit 1
}

# 1. Backup existing
if (Test-Path $TargetDir) {
    Log "Backing up existing $TargetDir → $BackupDir"
    Copy-Item -Path $TargetDir -Destination $BackupDir -Recurse -Force
    OK "Backup created at $BackupDir"
} else {
    Log "No existing ~/.claude/ found, fresh install"
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

# 2. Preserve personal files
$Preserve = @("CLAUDE.local.md", "credentials.json", "history.jsonl")
$TmpDir = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "claude-config-preserve-$Stamp") -Force
foreach ($f in $Preserve) {
    $src = Join-Path $TargetDir $f
    if (Test-Path $src) {
        Copy-Item $src $TmpDir -Force
        Log "Preserving $f"
    }
}

# 3. Copy config files
Log "Installing config files..."
Copy-Item (Join-Path $SourceDir "CLAUDE.md") $TargetDir -Force
if (Test-Path (Join-Path $SourceDir "settings.json")) {
    Copy-Item (Join-Path $SourceDir "settings.json") $TargetDir -Force
}

foreach ($sub in @("rules", "scripts", "templates")) {
    $src = Join-Path $SourceDir $sub
    $dst = Join-Path $TargetDir $sub
    if (Test-Path $src) {
        if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst | Out-Null }
        Copy-Item -Path "$src\*" -Destination $dst -Recurse -Force
        OK "Installed $sub/"
    }
}

# 4. Restore preserved files
foreach ($f in $Preserve) {
    $src = Join-Path $TmpDir $f
    if (Test-Path $src) {
        Copy-Item $src $TargetDir -Force
    }
}
Remove-Item $TmpDir -Recurse -Force

# 5. Verify
Write-Host ""
Log "Running verification..."
$VerifyScript = Join-Path $RepoDir "tests\verify-install.ps1"
if (Test-Path $VerifyScript) {
    & $VerifyScript
} else {
    WarnMsg "verify-install.ps1 not found — skipping verification"
}

Write-Host ""
OK "claude-config v$Version installed successfully"
Write-Host ""
Write-Host "📂 Backup: $BackupDir"
Write-Host "📂 Active config: $TargetDir"
Write-Host ""
Write-Host "Next: open Claude Code in any project. The cascade audit will run automatically."
