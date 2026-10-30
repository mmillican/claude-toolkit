# Personal instructions (all projects, all agents)

These apply in every repo unless the repo's own `CLAUDE.md`/`AGENTS.md` says otherwise.
Linked into each agent's user-level instructions file by `install.ps1` / `install.sh` from
`claude-toolkit`; edit it there, not in the linked copy.

## Git

- Commit only when I ask. When I ask, show the commit grouping and messages first and wait
  for my OK, unless I said to go ahead without review (the `commit-groups` skill covers
  this).
- Never push, merge, rebase onto shared branches, or open/merge PRs unless I ask in words.
- Leave files I've staged as they are; they're staged on purpose.

## Writing

- In prose you write for me or for publication (docs, blog posts, issue bodies, PR
  descriptions, commit bodies): no em dashes and no stock AI phrasing. Use plain sentences,
  commas, colons, or parentheses instead.
- Don't invent URLs, API shapes, or file paths. Ask or leave a clear TODO.

## Plans

- Plans live in `docs/plans/yyyy-mm-dd-<slug>.md` at the repo root (`create-plan-doc`).
  Backend changes that affect the frontend get a frontend spec (`frontend-change-doc`).
- When I come back to a project and ask what's next, work it out from the plans and git
  history (`whats-next`) instead of asking me.

## Local dev

- Environment is Windows; I use PowerShell and Git Bash. Give PowerShell commands first.
- Before starting a dev server, check whether the port is already in use and whether I'm
  already running the stack (often via .NET Aspire). Don't kill processes you didn't start
  without asking.
- Line endings are LF.

## GitHub

- Use the `gh` CLI. If it lacks a scope, tell me the exact `gh auth refresh` command to run
  rather than retrying auth flows yourself.
