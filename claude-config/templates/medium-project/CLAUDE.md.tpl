# {{PROJECT_NAME}} — {{PROJECT_TYPE}}

> Comentario en español: {{ONE_LINE_PURPOSE_ES}}.
> Inherits: ~/.claude/CLAUDE.md (reglas globales aplican).

## Stack
- **Primary**: {{PRIMARY_STACK}}
- **Frameworks**: {{FRAMEWORKS}}

## Architectural decisions
- Layered: <describe layering pattern>
- Test pyramid: unit > integration > E2E
- See `docs/` for ADRs once they exist.

## Conventions
- Per `~/.claude/rules/code-quality-standards.md`.
- Commits with scope: `feat(<area>): ...`, `fix(<area>): ...`.

## Verification commands
- Test: `{{TEST_CMD}}`
- Build: `{{BUILD_CMD}}`
- Lint: `{{LINT_CMD}}`

## Per-module CLAUDE.md
Generated automatically when modules meet criteria (per `~/.claude/rules/per-module-claude-md.md`).
