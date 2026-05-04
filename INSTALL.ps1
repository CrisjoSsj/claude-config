# INSTALL.ps1 — non-destructive installer for Windows PowerShell.
#
# Comentario en español: NO sobreescribe configs existentes. Deep-merge de
# settings.json, marcadores en CLAUDE.md, no-clobber en rules/. Backup automático.

$ErrorActionPreference = "Stop"

$RepoDir   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SourceDir = Join-Path $RepoDir "claude-config"
$ToolsDir  = Join-Path $RepoDir "tools"
$TargetDir = Join-Path $env:USERPROFILE ".claude"
$Stamp     = Get-Date -Format "yyyy-MM-dd-HHmmss"
$BackupDir = Join-Path $env:USERPROFILE ".claude.backup.$Stamp"
$Version   = if (Test-Path "$RepoDir\VERSION") { (Get-Content "$RepoDir\VERSION" -Raw).Trim() } else { "unknown" }

function Log     { param($m) Write-Host "  $m" }
function OK      { param($m) Write-Host "  ✅ $m" -ForegroundColor Green }
function WarnMsg { param($m) Write-Host "  ⚠️  $m" -ForegroundColor Yellow }
function ErrMsg  { param($m) Write-Host "  ❌ $m" -ForegroundColor Red }
function Info    { param($m) Write-Host "  ℹ️  $m" -ForegroundColor Cyan }

Write-Host ""
Write-Host "🔧 Installing claude-config v$Version (non-destructive merge)"
Write-Host ""

if (-not (Test-Path $SourceDir)) {
    ErrMsg "Source dir not found: $SourceDir"
    exit 1
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    ErrMsg "Node.js required for safe merge. Install: https://nodejs.org/"
    exit 1
}

# 1. Backup
if (Test-Path $TargetDir) {
    Log "Backing up existing $TargetDir → $BackupDir"
    Copy-Item -Path $TargetDir -Destination $BackupDir -Recurse -Force
    OK "Backup created"
} else {
    Log "Fresh install — no existing ~/.claude/"
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

# 2. CLAUDE.md (marker-based merge)
Log "Merging CLAUDE.md (marker-based)..."
& node (Join-Path $ToolsDir "merge-claude-md.js") (Join-Path $TargetDir "CLAUDE.md") (Join-Path $SourceDir "CLAUDE.md")

# 3. settings.json (deep merge)
Log "Merging settings.json (deep merge)..."
$userSettings = Join-Path $TargetDir "settings.json"
$ourSettings  = Join-Path $SourceDir "settings.json"
if (Test-Path $userSettings) {
    & node (Join-Path $ToolsDir "merge-settings.js") $userSettings $ourSettings
} else {
    Copy-Item $ourSettings $userSettings -Force
    OK "settings.json: created (no existing user file)"
}

# 4. rules/ (no-clobber)
Log "Installing rules/ (no-clobber)..."
$rulesDst = Join-Path $TargetDir "rules"
New-Item -ItemType Directory -Force -Path $rulesDst | Out-Null
$rulesSrc = Join-Path $SourceDir "rules"
$skipped = @()
$added = 0
Get-ChildItem -Path $rulesSrc -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($rulesSrc.Length + 1)
    $dst = Join-Path $rulesDst $rel
    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
    if (Test-Path $dst) {
        $userHash = (Get-FileHash $dst).Hash
        $ourHash = (Get-FileHash $_.FullName).Hash
        if ($userHash -ne $ourHash) { $skipped += $rel }
    } else {
        Copy-Item $_.FullName $dst -Force
        $added++
    }
}
OK "rules/: $added new files added"
if ($skipped.Count -gt 0) {
    WarnMsg "rules/: $($skipped.Count) files differ from yours — kept yours:"
    $skipped | ForEach-Object { Write-Host "       - $_" }
}

# 5. scripts/ (always overwrite)
Log "Installing scripts/ (overwrite)..."
$scriptsDst = Join-Path $TargetDir "scripts"
New-Item -ItemType Directory -Force -Path $scriptsDst | Out-Null
Copy-Item -Path "$SourceDir\scripts\*" -Destination $scriptsDst -Recurse -Force
OK "scripts/: installed"

# 6. templates/ (no-clobber)
Log "Installing templates/ (no-clobber)..."
$tplDst = Join-Path $TargetDir "templates"
New-Item -ItemType Directory -Force -Path $tplDst | Out-Null
$tplSrc = Join-Path $SourceDir "templates"
$tplAdded = 0
$tplSkipped = 0
Get-ChildItem -Path $tplSrc -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($tplSrc.Length + 1)
    $dst = Join-Path $tplDst $rel
    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
    if (Test-Path $dst) {
        $tplSkipped++
    } else {
        Copy-Item $_.FullName $dst -Force
        $tplAdded++
    }
}
OK "templates/: $tplAdded new files, $tplSkipped existing files preserved"

# 7. CLAUDE.local.md scaffold
$localMd = Join-Path $TargetDir "CLAUDE.local.md"
if (-not (Test-Path $localMd)) {
    @"
# Personal — local-only (NOT pushed to repo)

> This file is gitignored. Add your personal identity, tone, language preferences,
> or project context here. Survives UPDATE.sh.

## Identity
- Name: <your-name>

## Conversation tone
- <your preferences>
"@ | Out-File -FilePath $localMd -Encoding utf8
    OK "CLAUDE.local.md: scaffold created"
} else {
    OK "CLAUDE.local.md: preserved (your existing file untouched)"
}

# 8. Verify
Write-Host ""
Log "Running verification..."
$VerifyScript = Join-Path $RepoDir "tests\verify-install.ps1"
if (Test-Path $VerifyScript) {
    & $VerifyScript
}

# 9. Summary
Write-Host ""
OK "claude-config v$Version installed (non-destructive)"
Write-Host ""
Write-Host "  📂 Backup:        $BackupDir"
Write-Host "  📂 Active config: $TargetDir"
Write-Host ""
Write-Host "  Preserved untouched:"
Write-Host "    - agents/, skills/, commands/, plugins/, sessions/, cache/"
Write-Host "    - history.jsonl, credentials.json, CLAUDE.local.md"
Write-Host "    - any rules/ files that already existed (with different content)"
Write-Host ""
Write-Host "  Merged safely:"
Write-Host "    - CLAUDE.md (only block between <!-- claude-config:start/end --> markers)"
Write-Host "    - settings.json (hooks union permissions union plugins union user keys)"
Write-Host ""
Write-Host "  Next: open Claude Code in any project. Cascade audit runs automatically."
