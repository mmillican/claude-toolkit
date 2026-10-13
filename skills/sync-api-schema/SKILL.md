---
name: sync-api-schema
description: Fetch an OpenAPI/Swagger spec (from a URL or file) and reconcile a frontend's TypeScript models and API service layer to match it — adding, changing, and removing types and endpoint methods while preserving the codebase's hand-authored naming and comment style. Use when the user wants to "sync the API schema", "regenerate models from the spec", "update the services from swagger", or refresh the client after backend contract changes.
---

# Sync API schema into models + services

Reads an **OpenAPI/Swagger spec** and reconciles the frontend's hand-authored **TypeScript
models** and **API service layer** so the client matches the current backend contract.

This is **not** deterministic codegen. The target files are curated by hand (JSDoc, domain-named
service methods, section banners, enum wire-format notes). The job is to *reconcile* — apply the
delta from the spec while preserving that editorial style — not to overwrite with machine output.

## Project configuration (optional)

This skill is repo-agnostic. If the current repo pins settings, read them from
`.claude/sync-api-schema.json` at the repo root and use them as defaults. Recognized keys
(all optional):

```jsonc
{
  "specUrl": "http://localhost:5000/swagger/v1/swagger.json", // where to fetch the spec
  "modelsFile": "app/models/index.ts",     // barrel of request/response types
  "servicesDir": "app/services",           // ApiService subclasses, one per resource
  "specDownloadCmd": "Invoke-RestMethod '{url}' | ConvertTo-Json -Depth 100 > '{out}'"
}
```

When the config is absent, fall back to discovery (below). An explicit instruction or URL the
user gives in the conversation always overrides both config and discovery.

## Inputs to resolve

1. **Spec source.** In order: a URL/path the user gave in the conversation → `specUrl` from
   config → discovery (search for a `swagger.json`/`openapi.json` reference in the repo, e.g. a
   comment like `generated from the OpenAPI spec (...)`, or a running dev server's `/swagger`).
   If none can be found, ask the user for the spec URL.
2. **Models file.** `modelsFile` from config, else discover the barrel that exports the
   `*Response`/`Create*`/`*Request` shapes (commonly `app/models/index.ts` or `src/models`).
3. **Services dir.** `servicesDir` from config, else discover the folder of classes that extend
   an `ApiService` base and call `this.get/post/put/delete`.

## Steps

1. **Fetch the spec to a local file in one shot.** Do **not** use WebFetch — it runs content
   through a model and mangles large JSON. Use a single shell command so it's one permission
   action. On Windows/PowerShell:
   ```
   Invoke-RestMethod '<specUrl>' | ConvertTo-Json -Depth 100 > .openapi-spec.json
   ```
   (curl/wget equivalent elsewhere). Write it to a gitignored temp path like `.openapi-spec.json`.
   Then **Read** the file — reads never prompt.
2. **Build the contract model.** From the spec's `components.schemas` and `paths`, enumerate:
   every schema (name, properties, types, nullability, enum values) and every operation (verb,
   route template, path/query params, request body schema, response schema + status).
3. **Reconcile the models file.** Diff spec schemas against the existing exported types:
   - **Add** new schemas as interfaces/enums, placed in the correct section and following the
     file's naming conventions (`*Response`, `Create*Command`, `*Request`, `*Input`, etc.).
   - **Update** changed shapes (new/removed/retyped/renullabled fields) in place.
   - **Remove** types that no longer exist in the spec (only if clearly spec-derived — never
     delete hand-authored, non-API types like auth/account view models).
   - Preserve JSDoc, section banners, enum wire-format comments, and ordering. Match the file's
     style; do not reformat untouched regions.
4. **Reconcile the services.** For each resource service, align its methods with the spec's
   operations for that route prefix:
   - Add methods for new endpoints, keeping the file's **domain-named** method style (e.g.
     `listRoots`, `attachPreset`) and the one-line `/** VERB /route */` doc comment.
   - Update routes/verbs/generics/params that changed; remove methods for deleted endpoints.
   - Keep the `this.get<T>()/post/put/delete` idiom and the trailing singleton export.
5. **Report the delta.** Summarize what changed grouped by Added / Changed / Removed, then run
   `git diff --stat` on the touched files so the user can review. Leave the temp spec file for
   inspection (or clean it up if the repo gitignores it) — do not commit anything.

## Zero-prompt setup (tell the user once)

The skill itself can't grant permissions. To run the whole sync without repeated prompts, the
repo's `.claude/settings.json` should pre-authorize the fetch and the two target paths:

```json
{
  "permissions": {
    "allow": [
      "Bash(curl:*)",
      "Edit(<modelsFile-glob>)",
      "Write(<modelsFile-glob>)",
      "Edit(<servicesDir>/**)",
      "Write(<servicesDir>/**)"
    ]
  }
}
```

If those rules aren't present, offer to add them (scoped to the model/service paths). The blunter
alternative is running the session in `acceptEdits` mode.

## Rules

- Reconcile, don't regenerate — preserve hand-authored comments, naming, and section structure.
- Never touch non-API hand-written types (auth/account/UI view models) even if absent from the spec.
- Enums that serialize as integers on the wire stay numeric; keep any wire-format notes.
- Always end with a change summary + `git diff --stat`; never commit.
