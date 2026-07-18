---
name: frontend-change-doc
description: Generate frontend change documentation from recent backend/API changes and save it as a dated frontend-spec Markdown file. Use when the user has made backend API changes (new/changed endpoints, request/response model fields, contract changes) and wants a frontend-facing spec describing what the UI team must do — i.e. "document the frontend changes", "write a frontend spec for this", "what does the frontend need to change".
---

# Generate frontend change documentation

Turns a set of **backend API changes** into a **frontend-facing change doc** that tells the
UI team exactly what the contract change is and what they need to build.

The audience is the **frontend developer**: they care about endpoints, JSON field names,
nullability, whether a change is additive or breaking, and the UI/UX implications — not the
backend internals.

## Project configuration (optional)

This skill is repo-agnostic. If the current repo pins settings, read them from
`.claude/frontend-change-doc.json` at the repo root and use them as defaults. Recognized keys
(all optional):

```jsonc
{
  "outputDir": "C:/path/to/frontend-repo/docs/plans", // where the doc is written
  "openApiSpec": "C:/path/to/frontend-repo/docs/api-spec.json", // for field-name cross-check
  "filenamePattern": "yyyy-mm-dd-<feature>-frontend-spec.md", // naming convention
  "styleDocs": ["docs/some-existing-frontend-spec.md"] // house-style references to match
}
```

When the config is absent, fall back to discovery (below). An explicit instruction from the
user in the conversation always overrides both config and discovery.

## Inputs to gather

1. **What changed.** Prefer changes already established in the conversation. If the context
   is thin, derive them from the working tree:
   - `git diff main...HEAD --stat`, then inspect the API-surface changes (controllers, request/
     response models) and the DTOs they map from.
   - Focus on the **consumer-visible** surface: route templates, HTTP verbs, status codes,
     and request/response model **field names + types + nullability**.
2. **Output location.** Resolve in this order:
   1. An explicit location the user gave in the conversation.
   2. `outputDir` from `.claude/frontend-change-doc.json`.
   3. **Discovery** — look for a sibling/related frontend repo and an existing folder of
      `*-frontend-spec.md` docs (commonly `docs/plans` or `docs/`). If found, use it.
   4. Fall back to `docs/frontend-specs/` in the **current** repo.
3. **Filename.** Use `filenamePattern` if configured; otherwise match the target folder's
   existing convention. Default: `yyyy-mm-dd-<feature>-frontend-spec.md` (kebab-case, today's
   date prefix). Check the folder first and follow whatever pattern is already there; don't
   invent a new one.

## Steps

1. **Identify the contract delta.** For each affected endpoint, determine the exact route
   (including any absolute `~/` overrides), verb, and the precise JSON shape before/after.
   **JSON is camelCase** (typical for ASP.NET / most web APIs) — write field names as the
   frontend sees them, not the backend's PascalCase/snake_case. Cross-check names against the
   OpenAPI export (`openApiSpec` from config, or a discovered `api-spec.json`/`openapi.json`)
   when present.
2. **Classify every change** as **additive** (new field/endpoint — nothing breaks) or
   **breaking** (renamed/removed/retyped/nullability-tightened). Call breaking changes out
   explicitly and up front.
3. **Capture non-obvious semantics** the UI must respect: nullable fields and what `null`
   means, values that are recomputed/refreshed vs cached, ordering/sorting guarantees, and
   any "this looks like an error but isn't" nuance that should shape UI copy.
4. **Match house style.** If the target folder already has `*-frontend-spec.md` docs (or
   `styleDocs` are configured), mirror their structure and tone rather than imposing the
   template below verbatim.
5. **Write the doc** using the template below.
6. **Save it.** Create the target directory if it doesn't exist, write the file, and report
   the absolute path. Do not modify anything else in the frontend repo.

## Doc template

```markdown
# <Area> — Frontend Changes (<Feature>)

<1–3 sentences, plain language: what behavior changed and why the frontend cares.>

<State whether the changes are additive (nothing breaks) or include breaking changes.>

## API changes

### `<VERB> <route>` — <what changed>

<Annotated JSON in a ```jsonc block. Mark new/changed fields with inline // NEW or
// CHANGED comments; show /* unchanged */ for elided existing fields. Use camelCase.>

- <Per-field notes: nullability, allowed values, ordering, when present/absent.>

## Field / contract notes

- <Additive vs breaking restated; refresh-vs-cache semantics; what null means; copy nuances.>

## Suggested UI flow

1. <Per-screen, numbered. What to render, where, and the empty/edge/error states.>

## Related

- <Link to the backend plan doc, related frontend docs, tickets.>
```

## Style rules

- Frontend reader, not backend: lead with endpoints and JSON, omit backend/ORM/handler detail.
- **camelCase** field names everywhere.
- Additive vs breaking is the first thing the reader needs — never bury a breaking change.
- Be explicit about `null`, recompute/refresh timing, and any conservative flags whose UI
  copy should say "review", not "error".
- Keep it tight and skimmable: annotated JSON + bullets, not prose walls. Match the tone of
  any existing frontend docs in the target repo.
