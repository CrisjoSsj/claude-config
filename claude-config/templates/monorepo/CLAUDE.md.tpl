# {{PROJECT_NAME}} — Monorepo

> Comentario en español: monorepo con N paquetes coordinados. Cada paquete es autocontenido.
> Inherits: ~/.claude/CLAUDE.md.

## Packages

| Package | Purpose | Status |
|---|---|---|
| {{PKG_1}} | {{PKG_1_PURPOSE}} | {{PKG_1_STATUS}} |
| {{PKG_2}} | {{PKG_2_PURPOSE}} | {{PKG_2_STATUS}} |

## Monorepo rules

1. **Each package is autocontained.** No cross-package runtime imports.
2. **If something is genuinely shareable**, duplicate with conscience first. Extract only after 3+ uses (rule of three).
3. **Each package has its own CLAUDE.md** with its conventions.
4. **Commits with scope**: `feat(<package>): ...`, `fix(<package>): ...`. Scope `monorepo` for root changes.
5. **Each package can diverge.** Don't force consistency.

## Architectural decisions
- See `docs/adr/` for full history.

## Per-package CLAUDE.md auto-cascade
Per `~/.claude/rules/project-detector.md`, each package gets:
- Its own `CLAUDE.md` (Apple-style)
- Its own per-module CLAUDE.md cascade if package is large.
