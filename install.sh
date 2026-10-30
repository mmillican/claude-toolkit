#!/usr/bin/env bash
# Link this toolkit's skills (and global/AGENTS.md) into every installed agent CLI.
# macOS/Linux counterpart of install.ps1; see that file for details.
#
#   ./install.sh                     # all git-tracked skills
#   ./install.sh commit-groups ...   # specific skills (tracked or not)
#   SKIP_GLOBAL=1 ./install.sh       # don't link global/AGENTS.md
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"

# agent-home:skills-dir:instructions-file (instructions empty = none)
agents=(
  ".claude:.claude/skills:.claude/CLAUDE.md"
  ".copilot:.copilot/skills:.copilot/copilot-instructions.md"
  ".codex:.codex/skills:.codex/AGENTS.md"
  ".gemini:.gemini/skills:.gemini/GEMINI.md"
  ".cursor:.cursor/skills:"
)

if [ "$#" -gt 0 ]; then
  skills=("$@")
else
  mapfile -t skills < <(git -C "$repo" ls-files -- 'skills/*/SKILL.md' | cut -d/ -f2 | sort -u)
fi
for s in "${skills[@]}"; do
  [ -f "$repo/skills/$s/SKILL.md" ] || { echo "No skill named '$s'" >&2; exit 1; }
done

for entry in "${agents[@]}"; do
  IFS=: read -r agent_home skills_dir instr <<<"$entry"
  [ "$agent_home" = ".claude" ] || [ -d "$HOME/$agent_home" ] || continue
  mkdir -p "$HOME/$skills_dir"

  linked=0; kept=0; skipped=()
  for s in "${skills[@]}"; do
    link="$HOME/$skills_dir/$s"; target="$repo/skills/$s"
    if [ -L "$link" ]; then
      [ "$(readlink "$link")" = "$target" ] && { kept=$((kept+1)); continue; }
      rm "$link"
    elif [ -e "$link" ]; then
      skipped+=("$s"); continue
    fi
    ln -s "$target" "$link"; linked=$((linked+1))
  done

  pruned=0
  for link in "$HOME/$skills_dir"/*; do
    [ -L "$link" ] || continue
    t="$(readlink "$link")"
    case "$t" in "$repo/skills/"*) [ -f "$t/SKILL.md" ] || { rm "$link"; pruned=$((pruned+1)); } ;; esac
  done

  echo "$agent_home: linked $linked, unchanged $kept, pruned $pruned"
  [ "${#skipped[@]}" -eq 0 ] || echo "  skipped (real folder already there): ${skipped[*]}"

  if [ -z "${SKIP_GLOBAL:-}" ] && [ -n "$instr" ] && [ -f "$repo/global/AGENTS.md" ]; then
    dest="$HOME/$instr"
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$repo/global/AGENTS.md" ]; then
      echo "  instructions: up to date"
    elif [ -e "$dest" ] && [ ! -L "$dest" ]; then
      echo "  instructions: SKIPPED, $dest already exists (merge global/AGENTS.md by hand)"
    else
      ln -sfn "$repo/global/AGENTS.md" "$dest"; echo "  instructions: symlinked"
    fi
  fi
done
