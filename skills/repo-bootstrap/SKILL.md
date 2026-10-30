---
name: repo-bootstrap
description: Add the standard housekeeping files to a new or neglected repo (agent instructions file, README, .editorconfig, .gitignore, .gitattributes) and normalise line endings to LF, copying conventions from a reference repo the user names. Use when the user runs /init on a new project, says "add the .editorconfig and .gitignore", "include CLAUDE.md, README and the other repo files", "fix the line endings to LF", or "set this repo up like ProtoRail".
argument-hint: "[reference repo path to copy conventions from]"
---

# Bootstrap repo housekeeping

Give a repo the baseline files every project of the user's should have. Copy conventions
from a reference repo when one is named; otherwise use the defaults below.

## Steps

1. **Inventory.** Detect the stack(s) from project files (`*.csproj`/`*.sln`/`global.json`,
   `package.json`/`nuxt.config.*`, `pyproject.toml`, `project.godot`, `Dockerfile`, Terraform,
   etc.). List which baseline files already exist. Never overwrite an existing file
   silently: propose a diff or a merge.
2. **Reference repo.** If the user named one (e.g. `C:\_dev\ProtoRail`), read its
   `.editorconfig`, `.gitignore`, `.gitattributes`, `CLAUDE.md`/`AGENTS.md` and README
   structure, and adapt them, keeping only the sections that apply to this stack.
3. **Create or update:**
   - `.editorconfig`: `root = true`, `end_of_line = lf`, `charset = utf-8`,
     `insert_final_newline = true`, `trim_trailing_whitespace = true`; indentation per
     language (C# 4 spaces, JS/TS/Vue/JSON/YAML 2 spaces, Markdown keeps trailing
     whitespace). For .NET, carry over the reference repo's analyzer/style rules.
   - `.gitignore`: stack-appropriate (bin/obj, node_modules, .nuxt/.output, .env*, IDE folders,
     OS cruft, test-results).
   - `.gitattributes`: `* text=auto eol=lf`, plus binary markers (`*.png binary`, etc.) and
     any Windows-only scripts that need CRLF (`*.cmd`, `*.bat` → `eol=crlf`).
   - `README.md`: what it is, prerequisites, how to run, how to test, layout.
   - Agent instructions: if `/init` or another tool already generated `CLAUDE.md` or
     `AGENTS.md`, extend it; otherwise create `CLAUDE.md` covering purpose, commands
     (build/test/run with ports), layout, conventions, and commit rules. If the user uses
     several agent CLIs, suggest an `AGENTS.md` with `CLAUDE.md` pointing to it.
4. **Line endings.** After `.gitattributes` exists: show which tracked files are CRLF
   (`git ls-files --eol | grep crlf`), then run `git add --renormalize .` and show
   `git status`. Don't commit unless asked.
5. **Report** what was added or changed and anything that needs the user's input (license,
   ports, secrets setup).
