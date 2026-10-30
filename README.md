# claude-toolkit

A personal toolkit of agent skills, shared across projects via my user profile. Skills use
the [Agent Skills](https://agentskills.io) format (`skills/<name>/SKILL.md`), so the same
files work in Claude Code (CLI, desktop, IDE) and in other agent CLIs that read that
format: GitHub Copilot CLI, Codex CLI, Gemini CLI and Cursor.

## Layout

```
skills/
  archive-completed-plans/ — Audit a project's plans folder against the code and archive shipped plans
  commit-groups/           — Split pending changes into logical commits, approved before committing
  create-plan-doc/         — Save an implementation/design plan as a dated docs/plans/ file
  deploy-status/           — Check the latest deploy across sibling repos and why a change isn't live
  edit-blog-post/          — Edit a blog post draft for flow, grammar and readability
  frontend-change-doc/     — Turn backend API changes into a frontend-facing change spec
  gh-backlog/              — File GitHub issues with types, labels, milestones and project fields
  launch-readiness-review/ — PM-style go/no-go review before a launch or announcement
  repo-bootstrap/          — Add .editorconfig/.gitignore/.gitattributes/README/agent docs, LF endings
  sync-api-schema/         — Reconcile frontend models and services with an OpenAPI spec
  whats-next/              — Work out where a phased project left off and what comes next
  work-issue/              — Take a GitHub issue from investigation to plan, build and close-out
global/
  AGENTS.md                — Personal instructions linked into every agent's user-level instructions file
install.ps1 / install.sh   — Link skills and global/AGENTS.md into every installed agent
```

### Per-project configuration

Some skills are repo-agnostic but read optional per-project config from the repo they run in,
so project-specific paths live with the project rather than in this toolkit:

- `frontend-change-doc` reads `.claude/frontend-change-doc.json` (output dir, OpenAPI spec
  path, filename pattern, house-style docs). Without it, the skill falls back to discovery.
- `gh-backlog` reads `.claude/gh-backlog.json` (project owner/number, default repos, label
  prefixes, project fields). Without it, the skill discovers them with `gh`.
- `deploy-status` reads `.claude/deploy-status.json` (repo → deploy workflow file). Without
  it, the skill picks workflows whose names mention deploy/release.

## Installing

Run the installer from the repo root. It links every **git-tracked** skill into the skills
folder of each agent whose home folder exists, and links `global/AGENTS.md` as that agent's
user-level instructions file:

| Agent | Skills folder | Instructions file |
|---|---|---|
| Claude Code (always) | `~/.claude/skills/` | `~/.claude/CLAUDE.md` |
| GitHub Copilot CLI | `~/.copilot/skills/` | `~/.copilot/copilot-instructions.md` |
| Codex CLI | `~/.codex/skills/` | `~/.codex/AGENTS.md` |
| Gemini CLI | `~/.gemini/skills/` | `~/.gemini/GEMINI.md` |
| Cursor | `~/.cursor/skills/` | (none) |

**Windows** (PowerShell; junctions need no admin rights or Developer Mode):

```powershell
.\install.ps1            # all tracked skills
.\install.ps1 -WhatIf    # preview
.\install.ps1 -Name commit-groups,whats-next   # specific skills, tracked or not
```

**macOS / Linux:**

```bash
./install.sh
```

The installer is safe to re-run: it leaves correct links alone, replaces links that point
elsewhere, removes links to skills that were deleted from this repo, and never overwrites a
real file or folder (it reports those instead). Re-run it after pulling, after adding a
skill, or after installing a new agent CLI. Links are per-machine and are not committed.

Untracked skill folders (work in progress) are not installed until committed, unless named
with `-Name`.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md` with YAML frontmatter (`name`, `description`).
2. Keep `description` action-oriented: it's what the agent uses to decide when to invoke.
3. Commit, then run the installer.
