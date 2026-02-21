# GSD Workflow Commands — Installer / Updater (Windows PowerShell)
# Usage: irm https://raw.githubusercontent.com/ben-smith-atg/cursor-gsd/main/install.ps1 | iex
$ErrorActionPreference = "Stop"

$BASE  = "https://raw.githubusercontent.com/ben-smith-atg/cursor-gsd/main"
$DEST  = "$env:USERPROFILE\.cursor\commands\gsd"
$FILES = @(
    "setup-gsd.md",
    "spec-gsd.md",
    "plan-gsd.md",
    "build-gsd.md",
    "verify-gsd.md",
    "retro-gsd.md",
    "README.md"
)

New-Item -ItemType Directory -Force -Path $DEST | Out-Null

Write-Host "Installing GSD commands to $DEST ..."
Write-Host ""

foreach ($f in $FILES) {
    Invoke-WebRequest -Uri "$BASE/$f" -OutFile "$DEST\$f" -UseBasicParsing
    Write-Host "  v $f"
}

Write-Host ""
Write-Host "Done. $($FILES.Count) files installed to $DEST"
Write-Host "Restart Cursor to pick up the updated commands."
