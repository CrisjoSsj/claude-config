---
name: add-module
description: Generate a new module with Apple-style CLAUDE.md, hexagonal layers, and tests skeleton.
---

Generate a new module in the current project following project conventions.

Steps:

1. Ask user (if not specified):
   - Module name
   - Module purpose (one-line)
   - Layer it belongs to (backend/frontend/shared)
   - Whether it's stateful or stateless
2. Create module folder with hexagonal sub-structure:
   ```
   <module>/
   ├── CLAUDE.md         (Apple-style, EN+ES)
   ├── __init__.py / index.ts
   ├── domain/           (entities, value objects, ports)
   ├── application/      (use cases, services)
   ├── infrastructure/   (adapters)
   └── tests/            (unit + integration)
   ```
3. Generate `CLAUDE.md` per `~/.claude/rules/per-module-claude-md.md`:
   - H1 + one-line purpose in English
   - `> Comentario:` line in Spanish
   - `> Inherits: ../CLAUDE.md`
   - 5-12 bullets with EN directives + ES comments
   - Refs section (auto-populated from imports)
4. Generate test skeleton with one failing test (RED phase, per Strict TDD).
5. Update parent CLAUDE.md to include the new module bullet.
6. If decision is "big" (per `~/.claude/rules/claude-md-freshness.md`), generate ADR.
7. Save to Engram: `project/{name}/module/{module-name}`.
8. Report to user with file tree.
