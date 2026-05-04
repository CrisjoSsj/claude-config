# Refs & Routes Tracking — auto-update on path changes

> Comentario en español: cuando cambian rutas, paths o referencias, los CLAUDE.md de los módulos
> afectados deben actualizarse automáticamente. Sin esto, la IA y los humanos pierden el track
> de dónde está cada cosa.

## What counts as a "ref/route change"

Trigger update when ANY of:

1. **File path change**: rename, move, delete (detected via git status / git diff --name-status)
2. **Import path change**: `from X import Y` becomes `from Z import Y`
3. **API route change**: REST endpoint path, GraphQL operation name, RPC method
4. **URL/router change**: Next.js route, React Router path, Vue Router
5. **Module export change**: public API of a module (added/removed export)
6. **Database schema migration**: table rename, column rename, FK change
7. **Config key change**: env var renamed, settings key moved
8. **Inter-module contract change**: protocol/interface signature changed

## Detection mechanism

After every Write/Edit/file move, the PostToolUse hook runs `detect-structural-change.js`. The IA reads stderr in tool result and is OBLIGATED by this rule to update affected CLAUDE.md(s) in the same commit.

## What to update in each affected CLAUDE.md

For path/import changes:
- Section "Architecture decisions" or "Conventions": update bullet that mentions old path.
- Update `Inherits:` line if parent CLAUDE.md moved.
- Update example snippets that reference old path.

For route changes:
- Section "Routes / endpoints" (auto-create if missing): update list.
- Cross-reference: if API route changed, update FE module that calls it.

For schema migrations:
- Section "Persistence": update bullets that describe schema.
- Generate ADR if change is breaking.

For config key changes:
- Section "Configuration": update bullet.
- Update CLAUDE.local.md template if env var changed.

## The CLAUDE.md "Refs index" section (mandatory in large projects)

Each module CLAUDE.md gets a "Refs" section listing dependencies and consumers:

```markdown
## Refs
**Imports from:**
- ../shared/types — Domain types
- ../db — Database client

**Imported by:**
- ../api/users — Uses for auth check
- ../jobs/cleanup — Uses for batch ops

**API routes exposed:**
- POST /v1/auth/login
- POST /v1/auth/refresh
- DELETE /v1/auth/logout

**Config keys consumed:**
- AUTH_JWT_SECRET, AUTH_REFRESH_TTL_DAYS

**Database tables touched:**
- users, sessions, refresh_tokens
```

This section is auto-generated from static analysis on bootstrap and auto-updated by the PostToolUse hook on every change.

## Cross-module impact propagation

When module A's public API changes, the hook also flags module B (which imports A) as needing CLAUDE.md update if B's bullet referenced A's old API.

## Validation at session end (Stop hook)

`check-claude-md-freshness.js` does a final pass:
- Grep all CLAUDE.md for path/route mentions.
- Verify each path/route still exists.
- Report broken references before session closes.

## When user asks for a global rename / refactor

If user says "renombrá X a Y across the whole repo", the IA:

1. Plans the change first (uses plan mode if scope is wide).
2. Identifies ALL affected CLAUDE.md(s) and ADRs.
3. Updates code AND docs in same commit.
4. Runs Stop hook to verify no orphan references.
5. If decision affects ≥2 modules, generate ADR per `claude-md-freshness.md`.

## Anti-patterns

- DO NOT update code without updating CLAUDE.md mentions of old paths.
- DO NOT leave broken `@import` references in root CLAUDE.md.
- DO NOT batch "update docs later" — same commit, always.
