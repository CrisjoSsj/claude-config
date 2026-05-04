# Database Migration Safety — Zero-Downtime Patterns

> Comentario en español: en ERP, una migración mal hecha tira producción.
> Esta regla obliga el patrón **expand → backfill → contract** para cero downtime.

## The Three-Phase Migration Pattern (mandatory)

Never combine schema change + data backfill + code change in one release.

### Phase 1: EXPAND (release N)
- Add new column / table / index — nullable, no constraint, no FK requirements.
- Code writes to BOTH old and new schemas (dual write).
- Code reads from OLD schema.
- Deploy. Old code still works. New code starts populating new schema.

### Phase 2: BACKFILL (release N+1, or batch job)
- Backfill existing rows → populate new column from old data.
- Run as separate background job. NEVER in the migration itself.
- Validate backfill: count(NULL in new_col) should reach 0.

### Phase 3: CONTRACT (release N+2)
- Code reads from NEW schema only.
- Drop old column / table.
- Add NOT NULL / FK / CHECK constraints to new column.
- Deploy.

```
release N:    [expand: add new col nullable]    code writes both, reads old
release N+1:  [backfill: populate new col]      code writes both, reads new
release N+2:  [contract: drop old col + NOT NULL] code writes new only
```

## Forbidden in a single migration (will cause downtime)

| Operation | Why forbidden | Use instead |
|---|---|---|
| `ALTER COLUMN ... NOT NULL` on existing table | Locks table during scan | EXPAND nullable → BACKFILL → CONTRACT |
| `ADD COLUMN ... NOT NULL DEFAULT <expensive>` | Rewrites every row | EXPAND nullable → BACKFILL → CONTRACT |
| `RENAME COLUMN` | Code referencing old name breaks | Add new column → dual-write → drop old |
| `DROP COLUMN` referenced by running code | Code crashes | Stop reading first → drop in next release |
| `CREATE INDEX` (without `CONCURRENTLY` in PG) | Locks writes | Use `CREATE INDEX CONCURRENTLY` |
| `ADD FOREIGN KEY` validating existing rows | Locks both tables | `NOT VALID` → backfill check → `VALIDATE CONSTRAINT` |

## Reversibility checklist (mandatory before any migration ships)

- [ ] Migration has explicit `down()` / rollback SQL.
- [ ] `down()` is tested against a copy of prod data.
- [ ] No data is destroyed in `down()` (save state in a side table if needed).
- [ ] If destructive (DROP COLUMN/TABLE), at least 1 release has elapsed since EXPAND.
- [ ] Feature flag exists to toggle reading old vs new schema during transition.

## Dual-write pattern

During migration, application writes to both schemas:

```python
def update_customer_email(customer_id, new_email):
    # Phase 1: EXPAND
    customer = repo.get(customer_id)
    customer.email_legacy = new_email      # OLD column
    customer.contact_email = new_email     # NEW column (nullable)
    repo.save(customer)
```

After backfill complete, code transitions to read NEW only, then DROP OLD.

## Backfill safety

- Backfill in batches (1000-10000 rows). NEVER `UPDATE table SET col = ...` over millions of rows.
- Idempotent: rerunning the backfill produces same result.
- Throttled: monitor DB load; pause if replication lag exceeds threshold.
- Resumable: track progress in a side table (`migrations_progress`) so a crash doesn't restart from zero.
- Logged: every batch logs count + duration + last_id_processed.

## Schema change → CLAUDE.md update (auto)

When a migration is added, the PostToolUse hook detects it. The IA must:
- Update `CLAUDE.md` of the affected module: section "Persistence" with new schema.
- Generate ADR if change is breaking or non-obvious.
- Update `docs/business-rules/` if the change implements a regulatory requirement.

## Anti-patterns

- ❌ Creating + populating + constraining in one migration.
- ❌ `ALTER TABLE` blocking writes during peak traffic.
- ❌ Backfill SQL that holds a long transaction.
- ❌ Migration without rollback path.
- ❌ Renames without dual-column transition.
- ❌ Dropping columns immediately after adding new ones (skipping the dual-read phase).
