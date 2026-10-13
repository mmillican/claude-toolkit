---
name: archive-completed-plans
description: Review every plan doc in the current project's plans folder (default docs/plans/), check each one against the actual codebase and git history to see whether it's been built, and propose which ones can be archived. Use when the user asks to "clean up plans", "review the plans folder", "what plans are done", "archive completed plans", or wants to know what's left to build vs already shipped.
---

# Archive completed plan docs

Audits a project's plan/design docs against the real state of the codebase and reports
which ones describe work that's already shipped (archive candidates), which are partially
done, and which haven't been started. Never trust a plan's own claims about its status —
verify against code and git history.

## Where plans live

- **Default:** `docs/plans/` at the **repo root** (`git rev-parse --show-toplevel`).
- If that's empty or absent, check the project's `CLAUDE.md` / README for a documented
  convention before giving up.
- If an archive subfolder already exists (`docs/plans/archive/`, `docs/plans/done/`, etc.),
  note its name and reuse it rather than inventing a new one. Skip files already inside it.

## Steps

1. **List candidate plans.** All `*.md` files directly in the plans folder, excluding
   anything already in an archive subfolder.
2. **For each plan, extract**: the title/feature, the date in its filename, and the
   concrete, checkable things it describes building — entity/class names, endpoints,
   file paths, migrations, config keys.
3. **Gather evidence per plan** — don't skip this, a plan's prose is a claim, not proof:
   - `git log --oneline --since=<plan date>` and search commit subjects/bodies for the
     feature name or close synonyms.
   - `Grep`/`Glob` the codebase for the specific names the plan introduces (a class,
     endpoint route, migration name, config key). Absence of all of them is strong
     evidence nothing was built; presence of all of them plus a matching migration/test
     is strong evidence it's done.
   - Check for EF Core migrations whose name matches, if the plan describes a schema
     change.
   - If the plan was superseded or retired by a later decision (e.g. a later plan doc or
     a note in `CLAUDE.md` says "X was retired/replaced"), treat that as a resolution too
     — archive with a note of what superseded it, not just "built".
4. **Classify each plan**:
   - ✅ **Done / archive candidate** — everything it describes is present in code, and
     (when relevant) a migration or commit history backs it up.
   - 🔶 **Partially done** — some described pieces exist, others don't. Do not archive;
     list specifically what's missing.
   - ⏳ **Not started** — no evidence in code or git history.
   - 🚫 **Superseded/abandoned** — explicitly replaced by later work or a documented
     decision. Archive candidate, but note what replaced it.
5. **Report findings** as a table: file, status, evidence (1 line), recommendation.
   Lead with the archive candidates.
6. **Never move files without confirmation.** Present the list and ask before touching
   anything. If the user confirms:
   - Create the archive subfolder if it doesn't exist (match an existing name if found in
     step 1; otherwise `docs/plans/archive/`).
   - Use `git mv` for each file (preserves history), not a plain filesystem move/delete.
   - Don't edit the content of archived files unless the user asks.
7. **Report what moved** (or didn't) and leave everything else untouched.

## Rules

- Evidence-based only — a plan claiming "done" in its own text is not evidence; code and
  git history are.
- When uncertain between "done" and "partially done", call it partially done and say what's
  missing rather than guessing optimistically.
- Archive means **move**, never delete. The files stay in git history and in the archive
  folder.
- This skill is repo-agnostic: it adapts to whatever plans-folder convention and archive
  naming the project already has, rather than imposing one.
