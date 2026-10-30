---
name: work-issue
description: Take one or more GitHub issues (possibly spanning a backend and a frontend repo) from investigation through plan, implementation, frontend hand-off, and issue update/close. Use when the user says "review issue #12", "write a plan for services#22 and web-app#21", "investigate and fix services#17", "help me understand what's needed for #7", "evaluate what's required for #5", or "update and close the issue". Works phase by phase and stops for the user at each gate.
argument-hint: "<issue refs, e.g. services#22 web-app#21 or a GitHub URL>"
---

# Work a GitHub issue end to end

The loop this skill runs is: **understand → plan → implement → hand off → close out**.
Each phase ends at a gate where the user decides whether to continue. Start at whichever
phase the request names ("write a plan" starts at phase 2; "implement the plan" at phase 3;
"update + close the issue" at phase 5).

## Resolving issue refs

- `repo#N` → resolve `repo` against the current repo's owner, or against sibling repos
  documented in the project's `CLAUDE.md`/`AGENTS.md` (e.g. a "Sibling repos" section).
- `#N` alone → the current repo.
- A URL → use as given.
- Fetch with `gh issue view <N> --repo <owner/repo> --comments --json
  number,title,body,labels,state,milestone,assignees,comments`. If `gh` is not
  authenticated or lacks scope, say exactly which `gh auth` command fixes it and stop.

## Phase 1: Understand

1. Read the issue(s) and comments. Find the relevant code (search by the domain terms in the
   issue), existing plans in `docs/plans/`, and any linked issues.
2. Report: what the issue asks for, what exists today, what's missing, open questions, and a
   rough size. If the issue is already done or obsolete, say so and offer to close it.
3. **Gate:** ask whether to plan, fix directly (small bugs), or stop.

## Phase 2: Plan

1. Write the plan using the `create-plan-doc` skill if it is available; otherwise save it as
   `docs/plans/yyyy-mm-dd-<slug>.md` at the repo root. Reference the issue(s) at the top.
2. When an issue spans backend and frontend, write the backend plan in the backend repo and
   note that the frontend plan follows the API change (phase 4). Don't guess frontend
   contracts before the backend shape is settled.
3. List decisions you made and open questions. Offer to copy the open questions or a
   summary of the plan back onto the issue (`gh issue comment`). Only post when the user says
   yes.
4. **Gate:** wait for "continue/implement".

## Phase 3: Implement

1. Implement in the phases the plan defines. Follow the repo's `CLAUDE.md`/`AGENTS.md`
   conventions and existing patterns.
2. Run the project's build and tests (find the commands in the repo docs or project files).
   Report failures with their output; don't claim success you didn't verify.
3. If the work is risky or not ready for users, check whether the repo has a feature-flag
   mechanism and offer to put the change behind it.
4. Do **not** commit unless the user asks. When they do, use the `commit-groups` skill if
   available.
5. **Gate:** summarise what changed and what to check by hand (UI, deploy-only behaviour).

## Phase 4: Hand off (backend → frontend)

If the change altered an API contract, generate the frontend spec with the
`frontend-change-doc` skill if available (and update any checked-in OpenAPI/API docs the
repo keeps). Tell the user where the spec landed so they can start the frontend work with
"implement the plan in <path>".

## Phase 5: Close out

1. Compare what was built against the issue's acceptance criteria.
2. Propose an issue comment summarising the change (PR/commit refs, anything deferred).
3. Propose follow-up issues for deferred items or things discovered along the way. Use the
   `gh-backlog` skill if available so types/labels match the repo.
4. Post the comment, create the follow-ups, and close the issue only after the user
   confirms. If the fix isn't deployed or verified yet, suggest leaving it open.
