<#
.SYNOPSIS
  Link this toolkit's skills (and shared global instructions) into every installed agent CLI.

.DESCRIPTION
  Skills use the Agent Skills format (skills/<name>/SKILL.md), which Claude Code, GitHub
  Copilot CLI, Codex CLI, Gemini CLI and Cursor all read from a per-user skills folder.
  This script links each skill into the skills folder of every agent whose home folder
  exists (Claude is always included), so the repo stays the single source of truth.

  Skills are linked with directory junctions (no admin rights or Developer Mode needed).
  global/AGENTS.md is linked as each agent's user-level instructions file with a symlink,
  falling back to a hard link. Re-run after pulling: a hard link breaks when git rewrites
  the file.

  By default only skills tracked by git are installed, so work-in-progress skill folders
  stay out of your agents until committed. Use -Name to install specific skills anyway.

  Existing real files/folders are never overwritten; they are reported and skipped.

.PARAMETER Name
  Install only these skills (tracked or not).

.PARAMETER SkipGlobal
  Don't link global/AGENTS.md.

.PARAMETER WhatIf
  Show what would change without changing anything.

.EXAMPLE
  .\install.ps1
.EXAMPLE
  .\install.ps1 -Name commit-groups,whats-next -WhatIf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [string[]]$Name,
  [switch]$SkipGlobal
)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$homeDir = $env:USERPROFILE

# Agent → per-user skills folder and user-level instructions file.
# An agent is only targeted when its home folder already exists (Claude always is).
$agents = @(
  @{ Name = 'Claude Code';  Home = '.claude';  Skills = '.claude\skills';  Instructions = '.claude\CLAUDE.md' },
  @{ Name = 'Copilot CLI';  Home = '.copilot'; Skills = '.copilot\skills'; Instructions = '.copilot\copilot-instructions.md' },
  @{ Name = 'Codex CLI';    Home = '.codex';   Skills = '.codex\skills';   Instructions = '.codex\AGENTS.md' },
  @{ Name = 'Gemini CLI';   Home = '.gemini';  Skills = '.gemini\skills';  Instructions = '.gemini\GEMINI.md' },
  @{ Name = 'Cursor';       Home = '.cursor';  Skills = '.cursor\skills';  Instructions = $null }
)

function Get-LinkTarget([string]$path) {
  $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
  if ($null -eq $item -or $item.LinkType -notin @('Junction', 'SymbolicLink')) { return $null }
  return [string]($item.Target | Select-Object -First 1)
}

function Is-HardLinkTo([string]$path, [string]$target) {
  $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
  if ($null -eq $item -or $item.LinkType -ne 'HardLink') { return $false }
  # Target lists the file's other names.
  return [bool]($item.Target | Where-Object { Same-Path $_ $target })
}

function Same-Path([string]$a, [string]$b) {
  if (-not $a -or -not $b) { return $false }
  $norm = { param($p) ($p -replace '^\\\\\?\\', '' -replace '/', '\').TrimEnd('\').ToLowerInvariant() }
  return (& $norm $a) -eq (& $norm $b)
}

# --- which skills -------------------------------------------------------------
if ($Name) {
  $skills = $Name
} else {
  Push-Location $repo
  try {
    $skills = git ls-files -- 'skills/*/SKILL.md' |
      ForEach-Object { ($_ -split '/')[1] } | Sort-Object -Unique
  } finally { Pop-Location }
}
foreach ($s in $skills) {
  if (-not (Test-Path -LiteralPath (Join-Path $repo "skills\$s\SKILL.md"))) {
    throw "No skill named '$s' (expected skills\$s\SKILL.md)."
  }
}

$global = Join-Path $repo 'global\AGENTS.md'
$summary = @()

foreach ($agent in $agents) {
  $agentHome = Join-Path $homeDir $agent.Home
  if ($agent.Name -ne 'Claude Code' -and -not (Test-Path -LiteralPath $agentHome)) { continue }

  $skillsDir = Join-Path $homeDir $agent.Skills
  if (-not (Test-Path -LiteralPath $skillsDir)) {
    if ($PSCmdlet.ShouldProcess($skillsDir, 'Create folder')) {
      New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
    }
  }

  $linked = 0; $kept = 0; $skipped = @()
  foreach ($s in $skills) {
    $target = Join-Path $repo "skills\$s"
    $link = Join-Path $skillsDir $s
    $current = Get-LinkTarget $link
    if ($current -and (Same-Path $current $target)) { $kept++; continue }
    if ((Test-Path -LiteralPath $link) -and -not $current) { $skipped += $s; continue }
    if ($PSCmdlet.ShouldProcess($link, "Link to $target")) {
      if ($current) { (Get-Item -LiteralPath $link -Force).Delete() }
      New-Item -ItemType Junction -Path $link -Target $target | Out-Null
    }
    $linked++
  }

  # Prune links into this repo whose skill folder no longer exists.
  $pruned = 0
  if (Test-Path -LiteralPath $skillsDir) {
    Get-ChildItem -LiteralPath $skillsDir -Force | Where-Object { $_.LinkType -in @('Junction', 'SymbolicLink') } | ForEach-Object {
      $t = [string]($_.Target | Select-Object -First 1)
      $inRepo = ($t -replace '^\\\\\?\\', '' -replace '/', '\').ToLowerInvariant().StartsWith(($repo + '\skills\').ToLowerInvariant())
      if ($inRepo -and -not (Test-Path -LiteralPath (Join-Path $t 'SKILL.md'))) {
        if ($PSCmdlet.ShouldProcess($_.FullName, 'Remove stale link')) { $_.Delete() }
        $pruned++
      }
    }
  }

  # Global instructions.
  $globalNote = ''
  if (-not $SkipGlobal -and $agent.Instructions -and (Test-Path -LiteralPath $global)) {
    $instr = Join-Path $homeDir $agent.Instructions
    $current = Get-LinkTarget $instr
    $isHardLinkToGlobal = Is-HardLinkTo $instr $global
    if (($current -and (Same-Path $current $global)) -or $isHardLinkToGlobal) {
      $globalNote = 'instructions: up to date'
    } elseif ((Test-Path -LiteralPath $instr) -and -not $current) {
      $globalNote = "instructions: SKIPPED, $instr already exists (merge global\AGENTS.md into it by hand)"
    } elseif ($PSCmdlet.ShouldProcess($instr, "Link to $global")) {
      if ($current) { (Get-Item -LiteralPath $instr -Force).Delete() }
      try {
        New-Item -ItemType SymbolicLink -Path $instr -Target $global -ErrorAction Stop | Out-Null
        $globalNote = 'instructions: symlinked'
      } catch {
        New-Item -ItemType HardLink -Path $instr -Target $global | Out-Null
        $globalNote = 'instructions: hard-linked (re-run after pulling changes to global\AGENTS.md)'
      }
    }
  }

  $line = "{0,-12} {1}  linked {2}, unchanged {3}, pruned {4}" -f $agent.Name, $skillsDir, $linked, $kept, $pruned
  if ($skipped) { $line += "`n             skipped (real folder already there): " + ($skipped -join ', ') }
  if ($globalNote) { $line += "`n             $globalNote" }
  $summary += $line
}

$summary | ForEach-Object { Write-Host $_ }
