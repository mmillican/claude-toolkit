---
name: create-plan-doc
description: Save an implementation/design plan as a dated Markdown file under docs/plans/ in the current repo, using a yyyy-mm-dd-<feature>.md filename. Use whenever you produce a plan, design doc, or implementation strategy that should be written to disk — i.e. "write up a plan", "save this plan", "create a plan doc", or after planning a feature the user wants recorded.
---

# Create a dated plan document

Persist an implementation or design plan as a Markdown file so it lives with the
codebase and can be reviewed, committed, and referenced later.

## Where it goes

- **Directory:** `docs/plans/` at the **repo root** (the directory containing `.git`),
  regardless of your current working directory. Create it if it doesn't exist.
- **Filename:** `yyyy-mm-dd-<feature>.md`
  - `yyyy-mm-dd` is **today's date** (e.g. `2026-07-17`).
  - `<feature>` is a short kebab-case slug describing the plan (e.g. `bulk-edit-cars`).
  - Example: `docs/plans/2026-07-17-bulk-edit-cars.md`
- **Before writing, check the folder.** If `docs/plans/` already has files, match
  whatever naming/heading pattern is already established there rather than imposing
  this one. Only fall back to the convention above when the folder is empty or absent.

## Steps

1. **Find the repo root.** `git rev-parse --show-toplevel`. Resolve `docs/plans/`
   relative to that, not to the cwd.
2. **Pick the date and slug.** Use today's date. Derive a concise kebab-case slug from
   the feature name; keep it short and specific.
3. **Avoid clobbering.** If a file with the same name exists, either append to it (if
   it's the same plan) or add a short suffix (e.g. `-v2`, `-followup`) — never silently
   overwrite an existing plan.
4. **Write the plan** using the template below (adapt sections to fit; drop ones that
   don't apply rather than padding).
5. **Report the absolute path** of the file you wrote.

## Plan template

```markdown
# <Feature / change title>

<1–3 sentences: what this plan delivers and why.>

## Goal

<The outcome. What "done" looks like.>

## Context

<Relevant background: current behavior, constraints, related code/areas, decisions
already made.>

## Approach

<The strategy at a high level before the step list — key design choices and trade-offs,
and any alternatives considered and rejected.>

## Implementation steps

1. <Concrete, ordered steps. Reference specific files/modules where known.>
2. ...

## Risks / open questions

- <Anything unresolved, risky, or needing a decision.>

## Out of scope

- <Explicitly what this plan does not cover.>
```

## Notes

- This skill is repo-agnostic. If a specific repo defines its own plan convention
  (e.g. in `CLAUDE.md`), that convention wins — read it and follow it.
- Writing the file is the deliverable; don't also dump the full plan into chat unless
  the user asked to see it. A short summary plus the path is enough.
