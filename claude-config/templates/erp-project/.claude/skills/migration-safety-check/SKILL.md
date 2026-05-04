---
name: migration-safety-check
description: Check if a database migration is zero-downtime safe and reversible.
---

Audit a migration file (or a folder of migrations) for safety per `~/.claude/rules/erp/database-migration-safety.md`.

## Steps

1. Identify migration files in the change (Alembic, Flyway, Django migrations, etc.).
2. For each migration, check:
   - Is it EXPAND, BACKFILL, or CONTRACT phase?
   - Are operations safe to run during peak hours?
   - Is `down()` (or rollback) explicit and tested?
   - Are constraints added with `NOT VALID` then validated separately?
   - Are indexes created with `CONCURRENTLY` (PostgreSQL)?

3. Cross-check with application code:
   - Does code support BOTH old and new schemas during transition?
   - Is there a feature flag for gradual rollout?

4. Generate report:

```
🗄️ Migration safety check: alembic/versions/abc123_add_tax_id.py

🚨 CRITICAL (block):
- Statement: ALTER TABLE customers ADD COLUMN tax_id VARCHAR(50) NOT NULL DEFAULT 'PENDING'
  Why dangerous: locks customers table during full table rewrite.
  Fix: split into 3 migrations:
    1. ADD COLUMN tax_id VARCHAR(50) NULL
    2. (separate batch job) UPDATE customers SET tax_id = ... WHERE tax_id IS NULL
    3. ALTER COLUMN tax_id SET NOT NULL (in next release)

⚠️ HIGH:
- Statement: CREATE INDEX idx_customers_email ON customers(email)
  Why dangerous: locks writes during index build (PostgreSQL).
  Fix: CREATE INDEX CONCURRENTLY idx_customers_email ON customers(email)

ℹ️ MEDIUM:
- No explicit down() method. Add explicit rollback SQL.

✅ Phase: EXPAND (good — schema additive only)
✅ FK addition uses NOT VALID + later VALIDATE pattern.
✅ Reversibility: explicit down() exists.

📊 Summary:
- Migrations checked: 1
- Critical issues: 1
- High issues: 1
- Medium issues: 1

¿Aplicar fixes sugeridos?
```

5. If user accepts fixes, rewrite the migration applying the safe patterns.

6. Update CLAUDE.md "Persistence" section with the new schema.

7. Generate ADR if the migration represents a breaking change.

8. Save to Engram: `project/{name}/migration-check/{migration-file}`.
