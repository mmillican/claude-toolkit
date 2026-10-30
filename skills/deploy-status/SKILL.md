---
name: deploy-status
description: Check whether the latest deploy finished for the current repo and its sibling repos (GitHub Actions or Argo CD), and whether what's live matches the latest commit. Use when the user says "is the deploy done?", "monitor the deploy for both repos", "the changes have been deployed but I'm not seeing them", "did that ship?", or "watch the deploy action".
argument-hint: "[repo(s) or workflow name]"
---

# Deploy status

Tell the user, per repo, whether the latest deploy for the default branch succeeded, is
running, or failed, and whether the deployed version matches what they expect.

## Steps

1. **Repos.** The current repo plus sibling repos named in `CLAUDE.md`/`AGENTS.md` (or the
   repos the user lists).
2. **Find the deploy workflow.** `gh workflow list --repo <r>`; pick workflows whose name or
   file mentions deploy/release/publish/cd. Optional per-project config
   `.claude/deploy-status.json` can pin them:
   ```json
   { "repos": { "ProtoRail/services": "deploy.yml", "ProtoRail/web-app": "deploy.yml" } }
   ```
   If the project deploys via Argo CD or similar instead, check that (`argocd app get <app>`)
   when the CLI is available.
3. **Latest run.** `gh run list --repo <r> --workflow <w> --branch <default> --limit 3 --json
   databaseId,status,conclusion,headSha,displayTitle,createdAt,updatedAt,url`.
   Compare `headSha` with `git rev-parse origin/<default>` (after `git fetch`) to tell
   whether the newest commit has been deployed.
4. **On failure.** `gh run view <id> --repo <r> --log-failed`, then summarise the failing step
   and the likely cause in two or three lines.
5. **Still running.** If the user wants to wait, use `gh run watch <id> --repo <r>
   --exit-status` as a background command rather than polling in a loop, and report when it
   exits.

## "Deployed but I don't see it"

After confirming the run succeeded on the expected commit, check in order:
- the app exposes a version/commit (health endpoint, footer, `/_nuxt/` asset hashes) and
  whether it matches;
- container/service actually rolled (ECS service events, `kubectl rollout status`, Argo sync
  state);
- caching: CDN, service worker, browser cache (suggest a hard reload or private window);
- the change is behind a feature flag that is off in that environment.

## Report

One line per repo: `services: ✅ deployed abc1234 "fix signup" 12 min ago` /
`web-app: ⏳ running (4m)` / `❌ failed at "terraform apply" — <cause>` with run links.
