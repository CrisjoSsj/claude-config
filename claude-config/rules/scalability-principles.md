# Scalability Principles — Language-Agnostic Foundations

> Comentario en español: principios universales de escalabilidad. Aplican a CUALQUIER
> proyecto de tamaño medio/grande, sin importar el lenguaje (Python, TS, Go, Rust,
> Java, C#, Ruby, Elixir, Kotlin, etc.) ni el dominio (SaaS, mobile, ERP, e-commerce, IoT).
> Para escalabilidad ERP-específica, ver `erp/performance-at-scale.md`.

## Stateless services (default)

Services that handle requests must be **stateless**. State lives in:
- Persistent storage (database, object store).
- External cache (Redis, Memcached) for derived/cached state.
- Client (cookies, JWT, local storage) for session-scoped state.

Why: stateless = horizontally scalable. Add 10 more instances behind a load balancer with no coordination needed.

Forbidden:
- In-memory user sessions (`sessions: Map<userId, ...>` global).
- File-system writes for shared state (only ephemeral logs OK).
- Process-local counters or queues.

If you need shared state, use an external store. If you need a singleton (cron job leader), use a distributed lock (Redis SETNX, ZooKeeper, etcd, k8s lease).

## Idempotency (mandatory for retried operations)

Any operation that can be retried (network call, message handler, webhook receiver, cron job) MUST be idempotent.

Patterns:
- **Idempotency key**: client sends `Idempotency-Key: <uuid>` header. Server stores result keyed by it. Same key + same input → same result, no duplicate side effect.
- **Natural idempotency**: use `INSERT ... ON CONFLICT DO NOTHING` instead of plain INSERT. `SET status = 'paid'` instead of `INCREMENT amount`.
- **Outbox pattern**: events written to DB in same transaction as state change. Relay reads outbox and publishes. Duplicate publish OK (consumers idempotent too).
- **Deduplication window**: store recent event IDs for N minutes. Skip if seen.

## Async / event-driven by default

Synchronous calls couple lifecycles. If service B is down, service A breaks. Replace with:

- **Events**: A emits `OrderPlaced`, B subscribes. A doesn't care if B is up.
- **Message queues**: A puts work on a queue. B drains at its own pace. Backpressure handled by queue.
- **Webhooks**: A notifies B via HTTP POST. B retries on its end.

Forbidden:
- HTTP call from A to B as part of A's critical path, when B is internal.
- Long-running operations in HTTP request handlers (timeouts kill them).
- Tight loops polling another service.

## Backpressure (mandatory for async pipelines)

Producers must not overwhelm consumers. Patterns:

- **Bounded queues**: queue size capped. Producer blocks or drops when full.
- **Rate limiting**: limit per producer (token bucket, leaky bucket).
- **Circuit breakers**: when a downstream is failing, stop sending more for N seconds.
- **Bulkheads**: isolate failure domains. Upstream A failing doesn't drain threads needed for B.

NEVER unbounded queues / channels / promise pools — memory grows until OOM.

## Caching tiers

Three caching tiers, used together:

| Tier | Latency | Capacity | Use for |
|---|---|---|---|
| **CDN / edge** | <50ms global | TB | Static assets, public reads |
| **Distributed cache** (Redis, Memcached) | 1-5ms | GB | Hot data, computed results, sessions |
| **In-process** (LRU map) | <1µs | MB | Per-instance hot constants, request-scoped memos |

Rules:
- Cache key includes version/tenant/user as needed (never tenant-leak).
- TTL set explicitly. NEVER infinite. Long TTL + invalidation on write is OK.
- Stale-while-revalidate for high-traffic reads.
- Cache stampede prevention: lock on cache miss (only one regenerates, others wait).
- NEVER cache personally-sensitive data without encryption.

## Database scaling patterns

**Read scaling**:
- Read replicas with replication-lag-aware routing.
- Critical reads (after-write) → primary; eventual reads → replica.
- Query result caching for hot queries.

**Write scaling**:
- Sharding by tenant_id / user_id / region (last resort — increases complexity 10x).
- Vertical scaling first (bigger instance) until economics break.
- Async writes via outbox + background processor.

**Connection pooling**:
- Mandatory at app layer (HikariCP, pgbouncer, asyncpg pool).
- Pool size << DB max_connections (leave headroom).
- PgBouncer in transaction pooling mode in front of PostgreSQL.

## Observability (mandatory before scaling)

Cannot scale what you cannot measure. Required:

- **Metrics**: RED method (Rate, Errors, Duration) per endpoint. USE method (Utilization, Saturation, Errors) per resource. Cardinality controlled (no per-user labels).
- **Logs**: structured (JSON), with `trace_id` + `span_id` for correlation. Levels: ERROR, WARN, INFO, DEBUG. NEVER log PII at INFO.
- **Tracing**: OpenTelemetry (or vendor-specific). Sample 1-10% of traffic + 100% of errors.
- **SLO/SLI**: define service level objectives (99.9% availability, p99 < 500ms). Alert on burn rate, not on individual breaches.

## Failure isolation

Design for failure. Patterns:

- **Timeouts**: every external call has a timeout. NEVER infinite wait. Default: 5s for sync APIs, 30s for batch.
- **Retries with exponential backoff + jitter**: 3 attempts, 100ms / 500ms / 2s delays + ±25% jitter (avoids thundering herd).
- **Circuit breakers**: 50% errors over 10s → open circuit, fail-fast for 30s, then half-open test.
- **Graceful degradation**: feature off when downstream fails. User sees cached/default value, not 500.
- **Bulkheads**: separate thread/connection pools per dependency. Failure of slow dep doesn't block others.

## Stateless deployments

Deploy with these properties:

- **Immutable infrastructure**: build once, deploy artifact (Docker image, JAR, binary). NEVER `pip install` on prod box.
- **Health checks**: `/healthz` (alive) + `/readyz` (ready to serve traffic). Differentiate.
- **Graceful shutdown**: SIGTERM → stop accepting new requests, drain in-flight, exit. NO in-memory state to persist.
- **Rolling deploys**: replace instances gradually, never all at once.
- **Feature flags**: toggle features without redeploying. Rollback in seconds.

## Observability-driven sizing

Don't size by guess. Use:

- **Load tests**: synthetic load reaching p99 SLO. Use k6, Gatling, JMeter, Locust.
- **Capacity buffer**: provision for 2-3x peak observed traffic.
- **Auto-scaling**: HPA on CPU+memory in k8s, or LB-based on request rate. Scale-out fast (10s), scale-in slow (5m) to avoid flapping.

## Anti-patterns

- ❌ In-memory state in horizontally-scaled service.
- ❌ Synchronous HTTP chains across 5+ internal services.
- ❌ Unbounded queues / unbounded retries.
- ❌ Cache without TTL.
- ❌ Missing timeout on external call.
- ❌ Logs without correlation IDs.
- ❌ Metrics with per-user / per-request-id labels (cardinality explosion).
- ❌ Database query plans not reviewed before deploy.
- ❌ Singleton coordination via "first instance wins" race.
- ❌ Manual scaling decisions without load test data.

## When to NOT apply (avoid premature scaling)

- App < 100 RPS and < 1k users → premature optimization. Build the feature first.
- Single-region, single-tenant MVP → don't add Redis + queues + replicas day 1.
- Rule of thumb: optimize when CURRENT load × 5 would break the system, not before.

Scalability has a cost (operational complexity). Pay it when scale demands it, not before. But design boundaries (stateless, idempotent, async-friendly) so you CAN scale when needed without rewrite.
