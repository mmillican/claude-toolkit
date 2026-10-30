---
name: whats-next
description: Reconstruct where a multi-phase project left off and say what comes next, from the plan docs, milestones, git history, open branches and open issues. Use when the user says "where were we?", "I lost my last session", "what's next?", "what's step 6?", "I don't remember what's next", "give me a recap of what's done", "continue to the next phase/milestone", or returns to a project after a break.
argument-hint: "[optional: phase/step/milestone name, e.g. \"step 6\" or \"M4\"]"
---

# What's next?

Answer "where are we and what's next" from evidence in the repo, not from memory. Keep the
answer short; link to existing docs instead of repeating them.

## Gather (read-only)

Run these and skim the results; don't dump them on the user.

1. **Plans and roadmap:** `docs/plans/` (newest first, skip `archive/`), plus README or
   ROADMAP sections that list milestones, phases, or steps. Note each plan's phases and any
   checkboxes or "Status" lines.
2. **Git:** current branch, `git status`, `git log --oneline -25`, unmerged local branches
   (`git branch --no-merged`), and the last commit date.
3. **Issues/PRs (if `gh` works):** open PRs by the user, open issues in the current
   milestone or project. Skip silently if `gh` isn't available.
4. **Uncommitted work:** a dirty tree usually means the last session stopped mid-step.

## Decide

- Match each plan phase/step to commits (by message, files touched, or the presence of the
  code it describes). Mark it **done**, **in progress**, or **not started**.
- If the user named a step ("step 6", "M4"), find it in the plan and describe exactly that.
- If plans disagree with the code, trust the code and say the plan is stale.

## Answer

Use this shape:

```
**Where you are:** <plan name> — phase 2 of 4 (link). Branch `x`, 3 uncommitted files.
**Done recently:** 2-4 bullets with commit/PR refs.
**Next:** the one next step, with what it involves (2-3 lines) and a link to the plan section.
**Then:** the step after, one line.
**Loose ends:** uncommitted work, unmerged branches, stale plans (only if any).
```

End by offering to start the next step. Don't start it until the user says so. If several
plans are in flight, list them and ask which one to pick up.
