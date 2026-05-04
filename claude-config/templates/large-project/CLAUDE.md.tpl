# {{PROJECT_NAME}} — {{PROJECT_TYPE}}

> Comentario en español: {{ONE_LINE_PURPOSE_ES}}.
> Este es un proyecto grande ({{SIZE}}) con stack {{PRIMARY_STACK}}.
> Inherits: ~/.claude/CLAUDE.md (reglas globales del usuario aplican siempre).

## Stack
- **Primary**: {{PRIMARY_STACK}}
- **Frameworks**: {{FRAMEWORKS}}
- **Database**: {{DATABASE}}
- **Infra**: {{INFRA}}

## Architectural decisions
- See `docs/adr/` for full decision history (per `~/.claude/rules/claude-md-freshness.md`).
- Currently accepted ADRs:
  - ADR-0001: Record architecture decisions
  <!-- Más ADRs se agregarán acá automáticamente cuando se generen -->

## Top-level structure
```
{{PROJECT_NAME}}/
├── backend/          # API + business logic
├── frontend/         # UI client
├── shared/           # Cross-cutting types and utils
├── docs/
│   ├── ARCHITECTURE.md
│   ├── GLOSSARY.md
│   └── adr/          # Architecture Decision Records (append-only)
├── .claude/
│   ├── settings.json
│   ├── agents/
│   ├── skills/
│   └── commands/
└── .github/
```

## Glossary
- **{{TERM_1}}**: {{DEFINITION_1}}
- **{{TERM_2}}**: {{DEFINITION_2}}
<!-- Comentario: agregar términos del dominio del negocio acá conforme aparecen -->

## No-touch areas
- `migrations/` — never edit existing migrations, only add new ones.
- `docs/adr/*.md` accepted — append-only, never edit (per ADR convention).
- `.github/workflows/` — discuss before changing CI.

## Conventions
- Commits with scope: `feat(backend): ...`, `fix(frontend): ...`, `chore(monorepo): ...`.
- Branch naming: `feature/<slug>`, `fix/<slug>`, `chore/<slug>`.
- PR template: `.github/PULL_REQUEST_TEMPLATE.md`.

## Per-module CLAUDE.md
- `backend/CLAUDE.md`, `frontend/CLAUDE.md`, etc. provide module-specific context.
- Generated/maintained per `~/.claude/rules/per-module-claude-md.md`.

## Verification commands (use BEFORE declaring "listo")
- Backend tests: `{{BACKEND_TEST_CMD}}`
- Frontend tests: `{{FRONTEND_TEST_CMD}}`
- Build: `{{BUILD_CMD}}`
- Lint: `{{LINT_CMD}}`
- Type check: `{{TYPECHECK_CMD}}`
