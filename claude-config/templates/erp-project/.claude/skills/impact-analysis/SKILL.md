---
name: impact-analysis
description: Compute blast radius of a change — affected modules, tests, DB, downstream consumers.
---

Compute the cross-module impact of a change before merging.

## Input

- A file path, module path, OR a git diff range (e.g. `HEAD~3..HEAD`).

## Steps

1. Identify the changes (use `git diff` to get the actual changes).
2. For each changed file, determine:
   - Public API changed? (exports, function signatures, route paths)
   - Database schema changed? (migration files)
   - Domain event changed? (event class, payload fields)
   - Configuration changed? (env vars, settings keys)
   - Shared utility / middleware changed?

3. For each detected change, compute downstream impact:

   ### Code consumers
   ```bash
   grep -rn "from <module> import <thing>" --include="*.py"
   grep -rn "import { <thing> } from '<module>'" --include="*.ts" --include="*.tsx"
   ```

   ### Event consumers
   - Scan event bus subscriptions for `<EventName>`.
   - Read each consumer's CLAUDE.md "events consumed" section.

   ### API consumers (frontend + mobile + integrations)
   - Grep for endpoint path in `frontend/`, `mobile/`, `integrations/`.

   ### Database consumers
   - Grep migrations for table/column references.
   - Grep raw SQL queries.

   ### Test coverage
   - Identify tests touching the changed files.

4. Read the CLAUDE.md "Refs" section of each downstream module to map dependencies.

5. Generate report:

```
🔍 Impact analysis of <change>:

📦 Modules directly affected:
- backend/sales/order_service.py (function `place_order` signature changed)

📦 Downstream consumers:
- backend/billing/ — calls sales.place_order from invoice_service.py:42
- backend/inventory/ — subscribes to OrderPlaced event (3 handlers)
- backend/reporting/ — joins on orders.total column (2 SQL queries)
- frontend/dashboard/ — fetches POST /v1/orders (1 hook)
- mobile/ — fetches POST /v1/orders (1 service)
- integrations/sap/ — pushes orders to SAP (1 transformer)

🗄️ Database impact:
- orders.total column type change (DECIMAL(10,2) → DECIMAL(19,4))
- 3 indexes need rebuild
- 2 reporting views reference this column

🧪 Tests at risk (coverage):
- backend/sales/tests/ — 14 unit tests, 8 integration tests
- backend/billing/tests/ — 5 tests touching invoice creation
- E2E: "place order" journey (3 scenarios)

📋 ADR required: YES (breaking API change)

⚠️ Risks:
- billing/ assumes USD-only, this change introduces multi-currency
- old mobile app versions read total as 2-decimal — backwards compat?
- reporting aggregations may need migration

🚦 Recommendation:
- Generate ADR documenting the rationale
- Apply EXPAND → BACKFILL → CONTRACT for the DB column type change
- Add API versioning: keep /v1/orders returning 2-decimal, add /v2/orders with new format
- Update CLAUDE.md of affected modules in same PR
- Alert mobile team about backwards compat
```

6. Save to Engram: `project/{name}/impact-analysis/{date}/{change-id}`.

7. Suggest specific test commands to run for verification:
   ```
   pytest backend/sales/ backend/billing/ -v
   pytest tests/e2e/test_place_order.py
   ```
