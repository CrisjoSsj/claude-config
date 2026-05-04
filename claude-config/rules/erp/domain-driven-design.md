# Domain-Driven Design — Bounded Contexts & Aggregates

> Comentario en español: regla para proyectos ERP. Define cómo modelar el dominio
> con bounded contexts, aggregates, value objects y anti-corruption layers.
> Sin esto, los módulos se acoplan via objetos compartidos y el ERP se vuelve un
> Big Ball of Mud.

## Bounded Contexts (mandatory in ERP)

Each module is a **bounded context** with its own domain model, language, and lifecycle:

- `accounting/` — Money, Account, Transaction, Ledger
- `inventory/` — Product, Stock, Warehouse, Movement
- `sales/` — Order, Customer, Quote, Invoice
- `hr/` — Employee, Payroll, Leave, TimeEntry
- `procurement/` — Vendor, PurchaseOrder, Receipt

Rules:
- A `Customer` in `sales/` is NOT the same `Customer` in `accounting/`. They share an ID at most.
- NEVER share entity classes across contexts. Use **Anti-Corruption Layer (ACL)** to translate.
- Ubiquitous language: each context's CLAUDE.md lists ITS terms in `## Glossary`.

## Aggregate roots

Each bounded context has aggregates with a single root entity:

```
Order (root)
├── OrderLine (entity, only via Order)
├── ShippingAddress (value object)
└── Discount (value object)
```

Rules:
- Mutations to `OrderLine` go through `Order` (the root). NEVER touch `OrderLine` directly.
- Repositories return aggregates by ID, fully loaded.
- Cross-aggregate references = ID only, never object reference.
- Transaction boundary = aggregate boundary. One aggregate per DB transaction.

## Value Objects vs Entities

| Type | Identity | Mutability | Example |
|---|---|---|---|
| **Value Object** | by value | immutable | `Money(amount, currency)`, `Address`, `DateRange` |
| **Entity** | by ID | mutable through methods | `Customer`, `Order`, `Product` |

Rules:
- Value objects: `@dataclass(frozen=True)` (Python) / `record` (Java) / `data class` (Kotlin) / readonly struct (TS).
- Entities: never expose setters. Mutation only via methods that enforce invariants.

## Anti-Corruption Layer (ACL)

When `accounting/` needs `Customer` data from `sales/`:

```
sales.Customer ──[ACL translator]──→ accounting.AccountHolder
```

NEVER import `sales.Customer` into `accounting/`. Implement an ACL translator in `accounting/infrastructure/anticorruption/sales_acl.py` that maps the foreign type to your context's type.

## Domain Events

State changes that other contexts care about emit domain events:

```python
@dataclass(frozen=True)
class OrderShipped:
    order_id: OrderId
    shipped_at: datetime
    tracking: TrackingNumber
```

- Events are append-only.
- Other contexts subscribe via event bus or outbox pattern.
- NEVER call another context directly. Emit event → let them react.

## CLAUDE.md per bounded context (mandatory)

Each context root has a CLAUDE.md with this section:

```markdown
## Bounded context

- **Aggregates**: Order, Quote, Invoice (each with their root)
- **Value objects**: Money, Address, DateRange
- **Domain events emitted**: OrderPlaced, OrderShipped, OrderCancelled
- **Domain events consumed**: PaymentReceived (from billing/), StockReserved (from inventory/)
- **ACL adapters**:
  - `sales_to_accounting`: Customer → AccountHolder
  - `sales_to_shipping`: Order → ShipmentRequest
- **Public API**: see `application/services/*.py`
- **NOT exposed**: domain entities (only via use cases / DTOs)
```

## Anti-patterns

- ❌ Shared `models.py` with all entities → couples every module.
- ❌ One global `User` table joined everywhere → no bounded context isolation.
- ❌ Direct imports between contexts → use events + ACL.
- ❌ Mutating entities via setters → use methods that enforce invariants.
- ❌ Cross-aggregate transactions → split into multiple aggregates + saga.
