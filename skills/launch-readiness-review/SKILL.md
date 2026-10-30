---
name: launch-readiness-review
description: Review a product (app, API, marketing site) from a product-management perspective to decide whether it's ready to launch, announce, or open to new users, and write up blockers, nice-to-haves, and decisions the owner must make. Use when the user asks "is this ready to launch?", "should I send the announcement email?", "identify gaps before I open signups", "review this from a PM perspective", "release readiness", or "what's blocking launch?".
argument-hint: "[what's being launched, e.g. \"announcement email for v2\" or \"open signups\"]"
---

# Launch readiness review

Give the owner a clear go / not-yet answer with the shortest path to "go". Ground every
finding in code, config, or site content you actually checked, with file links.

## 1. Scope

- Work out what is being launched and to whom (announcement to a mailing list, opening
  signups, a public beta, a new version).
- Find all the pieces: app, API, marketing/docs site, infrastructure. Check `CLAUDE.md`/
  `AGENTS.md` for sibling repos and read them too.
- Read earlier audits/readiness docs and roadmap plans in `docs/`. Unresolved "must-fix"
  items from them are prime blockers.

## 2. Review

Work through [references/checklist.md](references/checklist.md). Skip sections that don't
apply. Send a one-line progress note between major areas on long reviews.

## 3. Classify

- **Blocker:** would embarrass, mislead, lose data, create legal exposure, or break the
  signup path for real users.
- **Nice to have:** improves the first impression; can ship after.
- **Decision for the owner:** things you can't determine from code (production feature-flag
  state, list size, approval capacity, pricing, whether "new version" implies a migration).

## 4. Write up

Save to `docs/yyyy-mm-dd-<topic>-readiness.md` at the repo root (match an existing
naming pattern if there is one). Structure:

1. **Verdict** in one or two sentences (ship / ship after X / not yet).
2. **Blockers**, numbered, each with evidence and a concrete fix.
3. **Nice to have**, top three first.
4. **Decisions you need to make.**
5. **What I couldn't check.**
6. **Suggested order** of work.

In chat, give the verdict and blockers, then offer to turn the findings into issues (via the
`gh-backlog` skill if available) or a shareable page.
