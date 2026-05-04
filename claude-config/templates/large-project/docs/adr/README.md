# Architecture Decision Records

> Comentario en español: índice de los ADRs de este proyecto. Auto-regenerado cuando se agrega un ADR nuevo.

| # | Title | Status | Date |
|---|-------|--------|------|
| 0001 | [Record architecture decisions](./0001-record-architecture-decisions.md) | accepted | {{DATE_TODAY}} |

## How to add a new ADR

Run the slash command `/new-adr` (defined in `.claude/commands/new-adr.md`) and the AI will:

1. Auto-number the next ADR.
2. Open template for filling.
3. Update this index.
4. Update root `CLAUDE.md` "Currently accepted ADRs" list.

## ADR lifecycle

```
proposed → accepted → deprecated
                   ↘ superseded by ADR-NNNN
```

Never edit accepted ADRs — supersede instead.

## References

- https://adr.github.io/
- https://learn.microsoft.com/en-us/azure/well-architected/architect-role/architecture-decision-record
