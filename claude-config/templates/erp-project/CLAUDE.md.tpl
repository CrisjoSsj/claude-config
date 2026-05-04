# {{PROJECT_NAME}} — ERP-grade {{PROJECT_TYPE}}

> Comentario en español: {{ONE_LINE_PURPOSE_ES}}.
> Proyecto ERP grande con bounded contexts, multi-tenancy, compliance, i18n.
> Inherits: ~/.claude/CLAUDE.md (reglas globales aplican siempre).

## Stack
- **Primary**: {{PRIMARY_STACK}}
- **Frameworks**: {{FRAMEWORKS}}
- **Database**: {{DATABASE}}
- **Cache**: {{CACHE}}
- **Message bus**: {{MESSAGE_BUS}}
- **Infra**: {{INFRA}}

## ERP-specific rules (loaded in addition to global)

@~/.claude/rules/erp/domain-driven-design.md
@~/.claude/rules/erp/database-migration-safety.md
@~/.claude/rules/erp/compliance-pii.md
@~/.claude/rules/erp/multi-tenancy.md
@~/.claude/rules/erp/i18n-money-time.md
@~/.claude/rules/erp/state-machines-workflows.md
@~/.claude/rules/erp/cross-module-impact.md
@~/.claude/rules/erp/performance-at-scale.md

## Architectural decisions
See `docs/adr/` for full history. Critical ADRs for ERP:
- ADR-0001: Record architecture decisions
- ADR-0002: Tenancy strategy (row-level | schema-per-tenant | db-per-tenant)
- ADR-0003: Reporting currency + FX rate source
- ADR-0004: Audit log design (append-only, signed)
- ADR-0005: Event bus + outbox pattern
- ADR-0006: Approval chain configurability

## Bounded contexts (top-level structure)

```
{{PROJECT_NAME}}/
├── accounting/      ← bounded context
├── inventory/
├── sales/
├── hr/
├── procurement/
├── shared/
│   ├── types/       ← cross-context types (Money, TenantId, EntityId)
│   ├── events/      ← shared event interfaces
│   └── infra/       ← outbox, audit log, FX rates, etc.
├── extensions/      ← per-tenant customizations
├── docs/
│   ├── adr/
│   ├── business-rules/  ← machine-readable business rules registry
│   └── compliance/      ← GDPR/SOX/HIPAA mapping per module
└── .claude/
    ├── agents/      ← specialized reviewers (compliance, migration, multi-tenancy)
    ├── skills/      ← ERP workflows (add-bounded-context, audit-pii, etc.)
    └── commands/    ← /impact-analysis, /audit-pii, /migration-check
```

## Glossary (domain ubiquitous language)

| Term | Bounded context | Definition |
|---|---|---|
| {{TERM_1}} | {{CONTEXT_1}} | {{DEFINITION_1}} |

## Compliance posture

- **Regulations applicable**: {{REGULATIONS}}
- **PII handling**: classified per `compliance-pii.md`. See `docs/compliance/`.
- **Audit log**: append-only, HMAC-signed, retention {{AUDIT_RETENTION}} years.
- **Data subject rights**: implemented via `/v1/admin/customers/{id}/personal-data` endpoints.

## Verification commands (BEFORE merging anything)

- Run pre-merge: `<your-pre-merge-command>` (lint + types + tests + impact + freshness)
- Test: `{{TEST_CMD}}`
- Migration safety check: `<your-migration-check>`
- PII audit: `<your-pii-audit>`
- Impact analysis: `/impact-analysis <changed-file>`

## Per-module CLAUDE.md cascade

Per `~/.claude/rules/per-module-claude-md.md` + `project-detector.md`, every bounded context has its own CLAUDE.md with:
- Aggregates, value objects
- Domain events emitted/consumed
- ACL adapters
- Public API
- Refs (auto-generated)
- Performance budget
- Multi-tenancy declaration
- i18n config
