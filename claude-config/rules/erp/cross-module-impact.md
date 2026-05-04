# Cross-Module Impact Analysis — Blast Radius

> Comentario en español: en ERP grande (>1000 archivos, >20 módulos) un cambio
> aparentemente local puede romper 5 módulos downstream. Esta regla obliga
> análisis de impacto antes de mergear.

## When mandatory

Run impact analysis BEFORE merging any change that affects:

- Public API of a bounded context (exports, function signatures, REST/GraphQL endpoints).
- Database schema (table, column, index, FK, constraint).
- Domain event payload (added/removed field, renamed event).
- Configuration key consumed by multiple modules.
- Shared utility, helper, or middleware.
- Authentication / authorization logic.

## What the analysis must produce

```
🔍 Impact analysis: <change description>

📦 Modules directly affected:
- backend/sales/ (3 files modified)

📦 Modules consuming the affected API (downstream):
- backend/billing/ — uses sales.Order.total via 4 call sites
- backend/inventory/ — subscribes to OrderShipped event (3 handlers)
- backend/reporting/ — joins on orders.id (2 SQL queries)
- frontend/dashboard/ — fetches /api/v1/orders (1 hook)

🧪 Tests at risk:
- 14 unit tests in sales/
- 8 integration tests crossing sales↔billing
- 3 E2E tests for "place order" journey

🗄️ Database impact:
- orders.total column type change (DECIMAL(10,2) → DECIMAL(19,4))
- 3 indexes need rebuild
- 2 reporting views reference this column

📋 ADR required: YES (breaking API change)

⚠️ Risks:
- billing/ assumes USD-only, this change introduces multi-currency
- reporting/ aggregations may need migration
- old mobile app versions read total as 2-decimal — backwards compat?
```

## Static analysis sources

The IA combines these to compute impact:

1. **Imports**: grep for `from <module> import` across the repo.
2. **Event subscribers**: scan event bus registrations / decorators.
3. **API consumers**: grep frontend code for endpoint paths.
4. **DB references**: grep migrations + queries for table/column names.
5. **Config consumers**: grep for env var / settings key references.
6. **Test coverage**: identify tests touching changed files (via coverage report).

## Output to PR description (mandatory section)

Every PR that triggers impact analysis appends to its description:

```markdown
## Impact analysis

**Public API changes**: <list>
**Downstream consumers**: <list of modules + line counts>
**Database changes**: <expand/contract phase, indexes, FKs>
**Tests at risk**: <list>
**Backwards compatibility**: yes/no — <details>
**Migration plan**: <expand → backfill → contract phases>
```

## CLAUDE.md "Refs" section maintained automatically

Per `refs-and-routes-tracking.md`, each module's CLAUDE.md keeps:

```markdown
## Refs (auto-generated)
**Imports from:** ../shared/types, ../db
**Imported by:** ../api/users, ../jobs/cleanup
**API routes exposed:** POST /v1/auth/login, ...
**Database tables touched:** users, sessions, refresh_tokens
**Domain events emitted:** UserLoggedIn, UserLoggedOut
**Domain events consumed:** PaymentReceived (from billing)
**Config keys consumed:** AUTH_JWT_SECRET, AUTH_REFRESH_TTL_DAYS
```

When you change exports/routes/events/schema, this section auto-updates. The `cross-module-impact` skill reads these sections to compute downstream impact.

## /impact-analysis slash command

Available in ERP project templates. Usage:

```
/impact-analysis backend/sales/order_service.py
```

The IA:
1. Reads the file's exports / public API.
2. Greps the repo for consumers.
3. Reads consumers' CLAUDE.md "Refs" sections.
4. Reports the full graph with risk assessment.
5. Suggests test commands to run (which tests cover the affected paths).

## Anti-patterns

- ❌ Refactoring a public function and shipping without checking who calls it.
- ❌ Renaming a DB column without checking all queries / migrations.
- ❌ Changing event payload structure without versioning.
- ❌ Removing config keys without scanning consumers.
- ❌ "Small" PRs that touch shared utilities — these have the largest blast radius.
- ❌ Skipping impact analysis because "tests will catch it" (E2E ≠ comprehensive).
