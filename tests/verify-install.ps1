# verify-install.ps1 — checks that %USERPROFILE%\.claude\ has all expected pieces.

$ErrorActionPreference = "Continue"
$Target = Join-Path $env:USERPROFILE ".claude"
$fail = 0

function Check {
    param($Label, $Path, $Expected = "")
    if (Test-Path $Path) {
        if ($Expected) {
            Write-Host "  ✅ $Label → $Expected"
        } else {
            Write-Host "  ✅ $Label"
        }
    } else {
        Write-Host "  ❌ $Label missing: $Path" -ForegroundColor Red
        $script:fail = 1
    }
}

function CountMd {
    param($Path)
    if (Test-Path $Path) {
        (Get-ChildItem -Path $Path -Filter *.md -File 2>$null).Count
    } else { 0 }
}

function CountImports {
    param($File)
    if (Test-Path $File) {
        (Select-String -Path $File -Pattern "^@" -SimpleMatch:$false 2>$null).Count
    } else { 0 }
}

function CountLines {
    param($File)
    if (Test-Path $File) {
        (Get-Content $File).Count
    } else { 0 }
}

Write-Host ""
Write-Host "🔍 Verifying ~/.claude/ install..."
Write-Host ""

$claudeMd = Join-Path $Target "CLAUDE.md"
Check "CLAUDE.md root" $claudeMd "$(CountLines $claudeMd) líneas, $(CountImports $claudeMd) imports"
Check "settings.json" (Join-Path $Target "settings.json")
Check "rules/" (Join-Path $Target "rules") "$(CountMd (Join-Path $Target 'rules')) archivos top-level"
Check "rules/stack/" (Join-Path $Target "rules\stack") "$(CountMd (Join-Path $Target 'rules\stack')) stack overlays"
Check "scripts/" (Join-Path $Target "scripts") "$(@(Get-ChildItem (Join-Path $Target 'scripts') -Filter *.js 2>$null).Count) scripts"
Check "templates/large-project/" (Join-Path $Target "templates\large-project")
Check "templates/medium-project/" (Join-Path $Target "templates\medium-project")
Check "templates/small-project/" (Join-Path $Target "templates\small-project")
Check "templates/monorepo/" (Join-Path $Target "templates\monorepo")

$rules = @("code-quality-standards","no-legacy-rule","per-module-claude-md","project-detector","claude-md-freshness","verification-first","context-discipline","plan-mode-trigger","ask-user-question","engram-protocol","sdd-orchestrator","refs-and-routes-tracking")
foreach ($r in $rules) {
    Check "rule: $r.md" (Join-Path $Target "rules\$r.md")
}

$scripts = @("block-sensitive-files","auto-format","detect-structural-change","check-claude-md-freshness")
foreach ($s in $scripts) {
    Check "script: $s.js" (Join-Path $Target "scripts\$s.js")
}

Write-Host ""
if ($fail -eq 0) {
    Write-Host "✅ Setup verified: all components present." -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ Setup incomplete. Re-run INSTALL.ps1." -ForegroundColor Red
    exit 1
}
