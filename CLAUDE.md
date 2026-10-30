# CLAUDE.md

## What this repo is

A personal toolkit of agent skills in the Agent Skills format. Each skill lives in
`skills/<skill-key>/` and is linked into the skills folder of every installed agent CLI
(Claude Code, Copilot CLI, Codex, Gemini, Cursor) by `install.ps1`/`install.sh` (see
[README.md](README.md)). `global/AGENTS.md` holds personal instructions linked into each
agent's user-level instructions file. There is no build, test suite, or app — the
deliverables are Markdown skill files.

## Repo layout

```
skills/<skill-key>/
  SKILL.md          # required: frontmatter + instructions
  references/       # optional: detail files SKILL.md points to, loaded on demand
```

- The directory name, the frontmatter `name`, and the commit-message prefix are all the same
  skill-key (kebab-case).
- Don't add files outside `skills/` unless they're repo-level docs (`README.md`, `CLAUDE.md`),
  the installers, or `global/AGENTS.md`.

## Authoring skills

Frontmatter:

- `name` — must match the directory name.
- `description` — action-oriented; says what the skill does *and* when to use it, including
  the trigger phrases a user might say. This is what Claude uses to decide when to invoke.
- `argument-hint` — include when the skill takes input (e.g. `<feature description>`).

Body:

- Write instructions to Claude, in the imperative. Be specific about steps, outputs, and
  stopping points (what to ask the user vs. decide).
- Keep `SKILL.md` focused. Push long templates, examples, and per-variant detail into
  `references/` and link to them from `SKILL.md`.
- Never hard-code project-specific paths, names, or URLs. Repo-agnostic skills read optional
  per-project config (e.g. `.claude/frontend-change-doc.json`) and fall back to discovery.
- Skills that write prose or code for the user must not silently overwrite existing files;
  produce a separate copy or report, or confirm first.
- Don't invent facts (URLs, API shapes, file paths). Ask or leave a clear TODO.
- Keep skills portable across agents: describe actions ("run", "ask the user", "use the
  `create-plan-doc` skill if available") rather than naming one agent's tools, and use only
  `name`, `description` and optional fields other agents ignore safely (`argument-hint`).
  Shell commands should work in PowerShell and POSIX shells, or give both.

## Keeping docs in sync

When adding, renaming, or removing a skill:

1. Update the `skills/` tree in [README.md](README.md).
2. If the skill reads per-project config, document it under "Per-project configuration".
3. Re-link on the local machine if the directory name changed (junction/symlink is not
   committed).

## Commit messages

Modified [Conventional Commits](https://www.conventionalcommits.org/): `<prefix>: <summary>`.

- Summary is imperative, lowercase, no trailing period, ~72 chars max (e.g. `update steps`, `add tests skill`).
- Add a body only when the *why* isn't obvious from the summary.

### Prefix

1. **Staged changes are for a specific skill** → use the skill's directory name (its skill-key) as the prefix, in place of a conventional type:
   - `edit-blog-post: ensure the edits are less-ai-y`
   - `add-entity: handle composite keys`
   - Use `skills/<skill-key>/` as the source of truth for the key.
2. **Anything else** → use a standard conventional type: `feat`, `fix`, `docs`, `refactor`, `chore`.
   - `docs: document PowerShell junction command for Windows install`
3. **Changes spanning several skills** → use a conventional type (usually `chore` or `refactor`), not a single skill-key.

Breaking changes: append `!` to the prefix (`edit-blog-post!: ...`) and explain in the body.

## Working conventions

- Environment is Windows; shell commands in docs should give PowerShell (and `cmd.exe` where
  relevant) alongside POSIX equivalents.
- Commit only when asked. Review `git status` first — untracked skill directories may be
  work in progress and shouldn't be swept into unrelated commits.
