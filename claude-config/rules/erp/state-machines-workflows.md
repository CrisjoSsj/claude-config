# State Machines & Workflows — Approval Chains, Sagas

> Comentario en español: en ERP cada documento crítico (orden, factura, leave request)
> tiene estados explícitos. Sin máquina de estados, hay race conditions y states
> imposibles. Esta regla obliga modelado explícito.

## Mandatory state machine for every long-lived entity

Any aggregate that changes status over time (Order, Invoice, LeaveRequest, PurchaseOrder, Payroll) MUST have an explicit state machine.

```python
class OrderStatus(Enum):
    DRAFT = "draft"
    SUBMITTED = "submitted"
    APPROVED = "approved"
    REJECTED = "rejected"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"
    REFUNDED = "refunded"

# Allowed transitions: explicit, validated.
TRANSITIONS = {
    OrderStatus.DRAFT:     {OrderStatus.SUBMITTED, OrderStatus.CANCELLED},
    OrderStatus.SUBMITTED: {OrderStatus.APPROVED, OrderStatus.REJECTED},
    OrderStatus.APPROVED:  {OrderStatus.SHIPPED, OrderStatus.CANCELLED},
    OrderStatus.SHIPPED:   {OrderStatus.DELIVERED, OrderStatus.CANCELLED},
    OrderStatus.DELIVERED: {OrderStatus.REFUNDED},
    OrderStatus.REJECTED:  set(),  # terminal
    OrderStatus.CANCELLED: set(),  # terminal
    OrderStatus.REFUNDED:  set(),  # terminal
}

class Order:
    def transition_to(self, new_status: OrderStatus, actor: User, reason: str = ""):
        if new_status not in TRANSITIONS[self.status]:
            raise InvalidTransition(self.status, new_status)
        # Pre-conditions per transition
        guard = self._guard_for(self.status, new_status)
        guard(self, actor)
        # State change + event
        old_status = self.status
        self.status = new_status
        self.events.append(StatusChanged(old_status, new_status, actor, reason))
```

## CLAUDE.md per aggregate (mandatory section)

```markdown
## State machine

States: draft → submitted → approved → shipped → delivered → refunded
                          ↘ rejected (terminal)
                          ↘ cancelled (terminal)

Transitions table:
- draft → submitted     (any user, requires line items)
- draft → cancelled     (only owner)
- submitted → approved  (manager role + budget check)
- submitted → rejected  (manager role + reason)
- approved → shipped    (warehouse role + stock check)
- approved → cancelled  (manager role + before shipping)
- shipped → delivered   (carrier webhook OR manual confirm)
- delivered → refunded  (manager role + refund_window not expired)
```

## Approval chains (multi-step approval)

For approvals requiring N people in sequence:

```python
@dataclass
class ApprovalChain:
    steps: list[ApprovalStep]
    current_step: int = 0

    def submit_approval(self, approver: User, decision: str, comment: str):
        step = self.steps[self.current_step]
        if not step.allows(approver):
            raise NotAuthorizedForThisStep
        step.record(approver, decision, comment)
        if decision == "rejected":
            self.status = "rejected"
            return
        self.current_step += 1
        if self.current_step == len(self.steps):
            self.status = "approved"
```

Rules:
- Approval steps are configurable per company (3-eyes vs 4-eyes vs amount-based).
- Approver assignment by role + delegation (out-of-office covers).
- Each approval signed (HMAC) for audit/SOX.
- Approval can be revoked only before next step starts.

## Saga pattern (long-running distributed transaction)

When a business operation spans multiple bounded contexts and can't be a single DB transaction:

```
Place Order saga:
  1. sales:        Reserve order in DRAFT
  2. inventory:    Reserve stock for 15 min  ← if fails, abort
  3. billing:      Charge payment            ← if fails, compensate inventory
  4. inventory:    Confirm stock reservation ← if fails, compensate billing (refund)
  5. shipping:     Create shipment           ← if fails, compensate billing + inventory
  6. sales:        Mark order CONFIRMED
```

Rules:
- Each step is idempotent (can be retried).
- Each step has a compensation action (undo).
- Saga state is persisted (orchestrator pattern OR choreography via events).
- Timeouts trigger compensation (e.g., reserve stock for 15 min, then auto-release).
- Status visible to user: "processing payment...", "reserving inventory...".

Saga implementation: prefer **outbox pattern** (events written to DB in same TX as state change, then published by relay) over direct synchronous calls.

## Workflow versioning

Long-running workflows (multi-day approvals) need versioning. A workflow started in version N keeps running on version N's logic even after version N+1 deploys.

```python
@workflow_version(2)
class LeaveApprovalWorkflow:
    ...
```

Stored: `workflow_instance.version = 2`. Code dispatches to the right handler by version.

## Outbox pattern (mandatory for cross-context events)

Never publish events directly from app code. Use outbox:

```python
def approve_order(order_id):
    with db.transaction():
        order = repo.get(order_id)
        order.transition_to(APPROVED, current_user)
        repo.save(order)
        outbox.append(OrderApproved(order_id))
    # Background relay polls outbox and publishes to message bus.
```

This guarantees: state change + event publication are atomic.

## Anti-patterns

- ❌ `if status == "draft": ...` scattered across codebase. Centralize in state machine.
- ❌ Setting `order.status = "shipped"` directly. Always go through `transition_to()`.
- ❌ Multi-context operations as one big DB transaction. Use saga.
- ❌ Direct event publishing without outbox (event lost if DB commit fails after publish).
- ❌ Approval chain where reject doesn't notify previous approvers.
- ❌ State machine without explicit terminal states.
- ❌ Workflows with implicit timeouts ("eventually").
