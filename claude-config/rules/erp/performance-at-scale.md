# Performance at ERP Scale — Beyond CWV

> Comentario en español: ERPs corren queries pesadas, batch jobs nocturnos,
> reports sobre millones de rows. Esta regla cubre patrones de performance
> que no aplican a webapps chiquitas.

## Performance budgets (ERP-grade)

| Metric | Target |
|---|---|
| API p50 (read) | <200ms |
| API p95 (read) | <500ms |
| API p99 (read) | <1500ms |
| API p95 (write) | <800ms |
| Background job throughput | depends on job, document SLO |
| Batch job (nightly) | complete within window |
| Report generation | <30s for online, async for >30s |
| Login | <500ms |
| Search (typeahead) | <100ms p95 |

## ORM N+1 prevention (mandatory)

Every list query that accesses related entities MUST use eager loading:

**Python / SQLAlchemy:**
```python
# WRONG
orders = session.query(Order).all()
for o in orders:
    print(o.customer.name)  # N+1

# RIGHT
orders = session.query(Order).options(selectinload(Order.customer)).all()
```

**Django:**
```python
# WRONG: N+1
for order in Order.objects.all():
    print(order.customer.name)

# RIGHT
for order in Order.objects.select_related("customer").all():
```

**JPA / Hibernate:**
```java
@EntityGraph(attributePaths = {"customer", "lines"})
List<Order> findByStatusOrderByCreatedDesc(Status status);
```

**Detection in CI**: pytest plugins like `nplusone` or Hibernate `BatchFetcher` should fail tests on N+1.

## Pagination always

NEVER return unbounded lists. Every list endpoint paginates:

```
GET /v1/orders?cursor=<opaque>&limit=50
```

- Cursor-based pagination (NOT offset) for tables >100K rows. Offset becomes O(n) on PostgreSQL with large offsets.
- Return `next_cursor` and `has_more`. NEVER `total_count` on huge tables (counting is expensive).
- Default limit = 50, max limit = 200. Reject > 200 with 400.

## Read replicas + write primary

Pattern:
- Writes (mutations, transactions) → primary DB.
- Reads (queries, reports) → read replica with replica lag awareness.
- Critical reads (e.g., balance check before transaction) → primary to avoid stale data.

```python
@route("/v1/customers/<id>", methods=["GET"])
def get_customer(id):
    return repo.from_replica().get(id)  # OK on replica

@route("/v1/orders", methods=["POST"])
def place_order(data):
    with db.primary() as session:
        # ALL of this on primary
        customer = session.query(Customer).filter_by(id=data.customer_id).first()
        ...
```

## Caching invalidation

Caching is mandatory for ERP scale. Invalidation rules:

- **Cache key includes tenant_id**. Never tenant-leak via shared cache.
- **Cache key includes version of the data shape** so a deploy with renamed fields doesn't serve stale shapes.
- **TTL**: short (5min) for dynamic, long (1h) for catalog data, very long (24h) for static config.
- **Invalidate on mutation**: every write that changes cached data emits an invalidation message. Use Redis pub/sub or events.
- **Stale-while-revalidate**: serve stale on cache miss + refresh in background, prevents thundering herd.

## Background jobs

ERPs do heavy nightly batches. Rules:

- **Idempotency**: jobs are safe to retry. Each batch records last_processed_id.
- **Resumability**: a crash mid-job restarts from last checkpoint, not zero.
- **Throttling**: monitor DB load, pause if replica lag > threshold.
- **Observability**: log start, progress every N rows, end with totals.
- **Concurrency control**: distributed lock per job name (1 instance only).
- **Failure isolation**: 1 row failing doesn't stop the batch — log and continue.

## Query budget per endpoint (mandatory in CLAUDE.md)

Each endpoint declares its query budget:

```markdown
## Performance budget

| Endpoint | DB queries | Cache hits expected | p95 budget |
|---|---|---|---|
| GET /v1/orders | ≤2 (with pagination) | 80% | 200ms |
| GET /v1/orders/{id} | ≤3 (order + lines + customer) | 90% | 100ms |
| POST /v1/orders | ≤5 (validate + insert + emit event) | n/a | 500ms |
```

CI test asserts: `assert query_count == declared_budget`. Drift triggers a failed build.

## Indexing strategy

- **Foreign keys**: index every FK column. Default in MySQL, manual in PostgreSQL.
- **Composite**: order matters. Most-selective column first.
- **Tenant-aware**: index `(tenant_id, <other-col>)` not `(<other-col>, tenant_id)`.
- **Partial indexes**: for queries filtering on a small subset (`WHERE status = 'active'`).
- **GIN/GIST** for JSONB columns queried with @> or @?.
- **NEVER** `CREATE INDEX` on prod without `CONCURRENTLY` (PostgreSQL).

## Report generation patterns

Reports over millions of rows:
- **Pre-aggregated tables**: hourly/daily rollups via materialized views or scheduled jobs.
- **Async**: long reports → enqueue job, email link when ready.
- **Streaming**: never load all data in memory; stream rows to CSV/Excel writer.
- **Cursor-based**: iterate with server-side cursors, not OFFSET.

## CLAUDE.md per module section

```markdown
## Performance

**Query budget per endpoint**: see table above
**N+1 prevention**: SELECT IN loading on Order.customer, Order.lines
**Caching**: customer profile (TTL 1h, invalidate on update), product catalog (24h)
**Background jobs**: nightly invoice generation (idempotent, resumable)
**Read replica usage**: list/search endpoints; primary for balance queries
**Monitoring**: APM traces with custom spans for slow queries (>100ms warn)
```

## Anti-patterns

- ❌ `SELECT *` on tables with TEXT/JSONB columns — pulls megabytes.
- ❌ N+1 in serializers (frontend gets list, serializer hits DB per item).
- ❌ Cache without invalidation on write.
- ❌ Background jobs without idempotency keys.
- ❌ COUNT(*) on large tables in API (use approx counts or pre-aggregate).
- ❌ Reports run synchronously in HTTP request (block threads).
- ❌ ORDER BY non-indexed column on huge tables.
- ❌ JOIN across hundreds of tables in one query — split into multiple roundtrips with caching.
