---
name: commit-groups
description: Split pending changes into logical, reviewable commits that follow the repo's commit-message convention, and show the grouping for approval before committing anything. Use when the user says "commit in logical groups", "commit as groups", "commit the work in groups", "make the commits", "commit and move on", or asks to commit a batch of mixed changes. Never pushes, merges, or opens a PR unless explicitly asked.
argument-hint: "[optional scope, e.g. \"only the staged files\" or \"backend only\"]"
---

# Commit in logical groups

Turn a working tree with mixed changes into a short series of focused commits. The user
reviews the plan first; nothing is committed until they approve it.

## Rules

- **Always propose before committing.** Show the grouping and messages and wait for an
  explicit go-ahead ("yes", "go", "commit"). Approval covers only the plan you showed.
  If you change the plan, show it again.
- **Exception:** if the user's request already said to commit without review (e.g. "just
  commit it, no need to show me"), proceed, then report what you committed.
- **Never push, merge, rebase, or open a PR** unless the user asked for that in words.
- **Respect staging.** If the user has already staged files, they chose those files on
  purpose. Ask whether to commit only the staged set, or the staged set plus the rest.
  Never unstage their work without asking.
- **Stage-only requests.** "Stage but don't commit" means stage the groups (or the first
  group) and stop.
- **Don't sweep up unrelated work.** Untracked directories, scratch files, local config,
  `.env*`, secrets, build output and large binaries stay out unless the user names them.
  List what you left out.

## Steps

1. **Read the state.** Run `git status --porcelain=v1 -b`, `git diff --stat`,
   `git diff --cached --stat`, and look at the actual diffs of anything unclear. Note the
   current branch. If it is the default branch (`main`/`master`) and the repo normally uses
   feature branches, say so in the proposal.
2. **Learn the message convention.** In order: the repo's `CLAUDE.md`/`AGENTS.md`/
   `CONTRIBUTING.md` commit rules, then the style of the last ~15 subjects in `git log
   --oneline`. Match prefixes, casing, scope style, and length. Default to Conventional
   Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`) if nothing is set.
3. **Group by intent, not by file type.** One commit = one reason to change. Good groups:
   - a feature slice (entity + migration + handler + endpoint + tests together),
   - a bug fix with its test,
   - a refactor with no behaviour change,
   - docs/plans, config/tooling, dependency bumps.
   Keep each commit buildable where practical: migrations travel with the model changes
   that need them, and a frontend change travels with the type changes it depends on.
   If a single file holds changes for two groups, split it with `git add -p`
   (non-interactively: build a patch and `git apply --cached`), or say it will go with the
   larger group.
4. **Propose.** Show a numbered list:
   ```
   1. feat(industries): add duplicate detection endpoint
      - src/.../DetectDuplicatesQuery.cs, src/.../IndustriesEndpoints.cs, tests/...
   2. docs: add frontend spec for duplicate detection
      - docs/plans/2026-10-11-...-frontend-spec.md
   Left out: .env.local, tmp/
   ```
   Then stop and wait.
5. **Commit.** For each group: stage exactly its paths, confirm with
   `git diff --cached --stat`, commit with the agreed message (add a body only when the
   *why* is not obvious). Add any attribution trailer the environment requires.
   If a pre-commit hook fails, stop, show the output, and fix or ask. Never bypass hooks.
6. **Report.** `git log --oneline -n <count>` plus anything still uncommitted.
