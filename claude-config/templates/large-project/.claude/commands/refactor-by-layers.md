---
description: Refactor a flat module into Hexagonal/Clean layers
---

Refactor the target module into Hexagonal/Clean Architecture layers.

Apply the canonical Hexagonal split: `core/` (domain types, errors, protocols — zero deps),
`config/` (settings + env), `<adapter>/` (infra adapters), `<use-case>/` (application services),
`api/` (wiring + endpoints).

Steps:

1. **Identify target module**: ask user or infer from cwd.
2. **Audit current structure**: file count, dependencies, imports.
3. **Propose layer structure**:
   - `core/` — domain types, errors, protocols (zero deps)
   - `config/` — settings, env loading
   - `<adapter>/` — infra adapters (audio, db, http, etc.)
   - `<use-case>/` — application services
   - `api/` — wiring (FastAPI/Express/etc. + HTTP/WS endpoints)
4. **Show user the proposed structure** before moving anything.
5. **On user OK**: move files via `git mv`, update imports.
6. **Generate per-module CLAUDE.md** for each new layer per `~/.claude/rules/per-module-claude-md.md`.
7. **Smoke test**: import the entry point, verify it resolves.
8. **Generate ADR** documenting the refactor decision.
9. **Apply NO LEGACY rule**: any quarantined `_legacy_*` files are eliminated, not archived.
10. **Commit** with scope: `refactor(<module>): split into hexagonal layers`.

Validation:
- Smoke import test passes.
- All imports resolve (no broken references).
- New CLAUDE.md files Apple-style (EN+ES).
- ADR generated and indexed.
