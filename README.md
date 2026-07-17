# claude-toolkit

A personal toolkit of [Claude Code](https://claude.com/claude-code) skills, shared
across projects via my user profile (`~/.claude`).

## Layout

```
skills/
  create-plan-doc/     — Save an implementation/design plan as a dated docs/plans/ file
```

## Installing a skill locally

Skills are discovered by Claude Code under `~/.claude/skills/`. Rather than copying,
link each skill into place from this repo so the repo stays the single source of truth.

On **Windows**, use a directory junction (no admin rights or Developer Mode needed).
From PowerShell:

```powershell
New-Item -ItemType Junction `
  -Path "$env:USERPROFILE\.claude\skills\create-plan-doc" `
  -Target "C:\_dev\claude-toolkit\skills\create-plan-doc"
```

Or from a native `cmd.exe` prompt (not Git Bash, which mangles the `/J` flag):

```bat
mklink /J "%USERPROFILE%\.claude\skills\create-plan-doc" "C:\_dev\claude-toolkit\skills\create-plan-doc"
```

On **macOS / Linux**:

```bash
ln -s "$PWD/skills/create-plan-doc" "$HOME/.claude/skills/create-plan-doc"
```

The link is per-machine and is **not** committed — re-run it after cloning on a new
machine.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md` with YAML frontmatter (`name`, `description`).
2. Keep `description` action-oriented — it's what Claude uses to decide when to invoke.
3. Link it into `~/.claude/skills/` as above, then commit.
