# GSD Workflow Commands — Installer / Updater (Windows PowerShell)
#
# Requires: gh CLI (https://cli.github.com) — authenticated with repo access
#
# Usage:
#   gh api repos/ben-smith-atg/cursor-gsd/contents/install.ps1 --jq '.content' `
#     | % { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) } `
#     | iex
#
# Or run locally after cloning:
#   . /path/to/cursor-gsd/install.ps1
$ErrorActionPreference = "Stop"

$REPO  = "ben-smith-atg/cursor-gsd"
$FILES = @(
    "setup-gsd.md",
    "spec-gsd.md",
    "plan-gsd.md",
    "build-gsd.md",
    "verify-gsd.md",
    "retro-gsd.md",
    "README.md"
)

# --- Tool selection ---
Write-Host ""
Write-Host "Install GSD commands for which AI tool?"
Write-Host "  1) Cursor"
Write-Host "  2) Claude Code"
$ToolChoice = Read-Host "Choice [1/2]"
Write-Host ""

if ($ToolChoice -eq "2") {
    $Tool     = "claude"
    $DEST     = "$env:USERPROFILE\.claude\commands\gsd"
    $ToolName = "Claude Code"
} else {
    $Tool     = "cursor"
    $DEST     = "$env:USERPROFILE\.cursor\commands\gsd"
    $ToolName = "Cursor"
}

# --- Substitution ---
# Strips tool-specific conditional markers and applies path/token substitutions.
# GSD source files use HTML comments to delimit tool-specific sections:
#   <!-- GSD-CURSOR-ONLY-START --> ... <!-- GSD-CURSOR-ONLY-END -->
#   <!-- GSD-CLAUDE-ONLY-START --> ... <!-- GSD-CLAUDE-ONLY-END -->
function Apply-Subs {
    param([string]$Content)

    if ($Tool -eq "claude") {
        # Remove cursor-only blocks entirely
        $Content = $Content -replace '(?s)<!-- GSD-CURSOR-ONLY-START -->.*?<!-- GSD-CURSOR-ONLY-END -->\r?\n?', ''
        # Strip claude-only markers (keep the content between them)
        $Content = $Content -replace '<!-- GSD-CLAUDE-ONLY-START -->\r?\n', ''
        $Content = $Content -replace '<!-- GSD-CLAUDE-ONLY-END -->\r?\n', ''
        # Path substitutions
        $Content = $Content -replace '\.cursor/rules/', '.claude/rules/'
        $Content = $Content -replace '\.cursor/plans/', '.claude/plans/'
        $Content = $Content -replace '\.cursor/commands/', '.claude/commands/'
        $Content = $Content -replace '\.mdc', '.md'
        $Content = $Content -replace 'cursor rules', 'project rules'
        $Content = $Content -replace 'Cursor rules', 'project rules'
        $Content = $Content -replace '`SemanticSearch`', 'the `Explore` agent (via Agent tool)'
        # Remove Cursor-specific frontmatter block from the setup-gsd config template
        $Content = $Content -replace '(?s)\r?\n---\r?\ndescription: GSD project configuration.*?alwaysApply: false\r?\n---', ''
        # Replace alwaysApply explanation note with Claude Code equivalent
        $Content = $Content -replace '.*alwaysApply.*false.*flag.*', '- **Context management**: Claude Code reads project rules only when explicitly referenced in skill prompts (via the Pre-Flight step), keeping them out of unrelated conversations.'
    } else {
        # Strip cursor-only markers (keep the content between them)
        $Content = $Content -replace '<!-- GSD-CURSOR-ONLY-START -->\r?\n', ''
        $Content = $Content -replace '<!-- GSD-CURSOR-ONLY-END -->\r?\n', ''
        # Remove claude-only blocks entirely
        $Content = $Content -replace '(?s)<!-- GSD-CLAUDE-ONLY-START -->.*?<!-- GSD-CLAUDE-ONLY-END -->\r?\n?', ''
    }
    return $Content
}

# --- Install ---
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "gh CLI is required. Install from https://cli.github.com"
    exit 1
}

New-Item -ItemType Directory -Force -Path $DEST | Out-Null

Write-Host "Installing GSD commands for $ToolName to $DEST ..."
Write-Host ""

foreach ($f in $FILES) {
    $b64     = gh api "repos/$REPO/contents/$f" --jq '.content'
    $bytes   = [System.Convert]::FromBase64String($b64)
    $raw     = [System.Text.Encoding]::UTF8.GetString($bytes)
    $content = Apply-Subs $raw
    [System.IO.File]::WriteAllText("$DEST\$f", $content, [System.Text.Encoding]::UTF8)
    Write-Host "  v $f"
}

Write-Host ""
Write-Host "Done. $($FILES.Count) files installed to $DEST"
if ($Tool -eq "cursor") {
    Write-Host "Restart Cursor to pick up the updated commands."
} else {
    Write-Host "Start a new Claude Code session to pick up the updated commands."
}

