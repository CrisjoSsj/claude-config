---
name: add-bounded-context
description: Generate a new bounded context with DDD structure (domain, application, infrastructure, ACL).
---

Generate a new bounded context following Domain-Driven Design.

## Steps

1. Ask user (if not specified):
   - Context name (e.g. "billing", "shipping").
   - Aggregate roots (1-3 names).
   - Public events emitted.
   - Public events consumed (from other contexts).

2. Create folder structure:
   ```
   <context>/
   ├── CLAUDE.md                          ← Apple-style with bounded context section
   ├── __init__.py / index.ts
   ├── domain/
   │   ├── __init__.py
   │   ├── <root_aggregate>.py            ← entity with state machine if applicable
   │   ├── value_objects.py               ← Money, Address, etc.
   │   ├── events.py                      ← domain events
   │   └── repositories.py                ← repository ports (abstract)
   ├── application/
   │   ├── __init__.py
   │   └── services/                      ← use cases
   ├── infrastructure/
   │   ├── __init__.py
   │   ├── persistence/                   ← repository implementations
   │   ├── outbox/                        ← event outbox table
   │   └── anticorruption/                ← ACL adapters to other contexts
   └── tests/
       ├── unit/                          ← domain tests, no I/O
       ├── integration/                   ← repository tests, real DB
       └── acceptance/                    ← saga tests with stubs
   ```

3. Generate aggregate root with:
   - Constructor enforcing invariants (tenant_id mandatory, valid state)
   - State machine if status changes over time
   - Methods that mutate via events (no public setters)
   - `events: list[DomainEvent]` collected on mutation

4. Generate value objects (frozen, hashable, equality by value).

5. Generate repository PORT (abstract):
   - `find_by_id(id, tenant_id) -> Aggregate | None`
   - `save(aggregate) -> None`
   - `next_id() -> AggregateId`

6. Generate failing test (RED) for the simplest use case (creating the aggregate).

7. Generate CLAUDE.md per `~/.claude/rules/per-module-claude-md.md` with sections:
   - Bounded context (aggregates, value objects, events emitted/consumed, ACL)
   - Public API
   - Refs (auto-generated)
   - Multi-tenancy declaration
   - i18n config
   - Performance budget

8. Update parent CLAUDE.md "Bounded contexts" section.

9. Generate ADR if cross-context contract is non-obvious.

10. Save to Engram: `project/{name}/bounded-context/{context-name}`.

11. Report file tree to user.
