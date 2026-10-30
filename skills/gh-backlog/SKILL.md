---
name: gh-backlog
description: File GitHub issues from a list of findings or story ideas with the right issue type, labels, repo, milestone, and GitHub Project (v2) fields such as Priority and Size; also re-prioritise or clean up existing issues and labels. Use when the user says "create GH issues for each of these", "add these stories to the backlog", "tag with type, effort and area", "add them to the project", "set the priorities on the project", "create a milestone and assign these", or "clean up labels".
argument-hint: "<findings or stories, or 'from the review above'>"
---

# File and organise backlog issues

Turn findings or story ideas into well-formed GitHub issues that land in the right repo,
with the repo's own taxonomy, and show up correctly in the project board.

## 0. Preflight

1. Confirm the **target repo(s)** from the current repo's remote and any sibling repos listed
   in `CLAUDE.md`/`AGENTS.md`. If the request looks like it belongs to a different project
   than the current directory, stop and ask before filing anything.
2. Check auth: `gh auth status`. Project fields need the `project` scope. If it is missing,
   tell the user to run `gh auth refresh -h github.com -s read:project,project` themselves,
   then wait. Don't loop on device-code flows.
3. Read optional per-project config `.claude/gh-backlog.json`:
   ```json
   {
     "project": { "owner": "ProtoRail", "number": 1 },
     "repos": { "default": "services", "frontendOnly": "web-app" },
     "labels": { "area": "area/*" },
     "fields": { "Priority": ["P0", "P1", "P2", "P3"], "Size": ["XS", "S", "M", "L", "XL"] }
   }
   ```
   Without it, discover everything in step 1.

## 1. Discover the taxonomy (don't assume)

- **Issue types:** `gh api graphql` on the org's `issueTypes` (e.g. Bug/Feature/Task). Use
  types instead of `type/*` labels when the org has them.
- **Labels:** `gh label list --repo <r> --limit 200`. Use existing labels only; never invent
  new ones without asking. If both a label and a project field express the same thing
  (priority, effort), prefer the project field and leave the label off.
- **Project fields:** `gh project field-list <number> --owner <owner> --format json` to get
  single-select field and option IDs.
- **Milestones:** `gh api repos/<owner>/<repo>/milestones`.

## 2. Draft and confirm

Show a table before creating anything:

| # | Repo | Title | Type | Labels | Priority | Size | Milestone |

- Titles: short, specific, outcome-focused.
- Repo: an issue needing both repos goes in the backend repo with an `area/web`-style label;
  frontend-only work goes in the frontend repo.
- Body: problem, context (file links), proposed approach, acceptance criteria, open
  questions. Write bodies to temp files and pass `--body-file` (avoids shell quoting and
  encoding issues on Windows).

Wait for approval or edits.

## 3. Create

1. `gh issue create --repo <r> --title ... --body-file ... --label ...`, then set the type via
   GraphQL `updateIssue(issueTypeId:)` if types are used.
2. Add to the project: `gh project item-add <number> --owner <owner> --url <issue-url>`, then
   set each field with `gh project item-edit --id <item> --field-id <f> --project-id <p>
   --single-select-option-id <o>`.
3. Milestones are per repo. If issues span repos, create a same-named milestone in each.
4. Spot-check one issue (`gh issue view`, plus the project item's fields) to confirm type,
   labels, body encoding, and fields came through.

## 4. Report

A table of created issues with links, priority, and size, plus any assumptions (e.g. how
priorities mapped onto the project's scale). Offer parent/sub-issue grouping if there's an
obvious epic.

## Re-prioritising and cleanup

- "Set the priorities": update the **project field**, not just labels, and confirm by reading
  the field back.
- "Clean up labels": list labels with usage counts, propose which to delete or merge, and
  only run `gh label delete` after the user confirms the exact list.
