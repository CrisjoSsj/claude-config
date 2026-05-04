# {{PROJECT_NAME}} — Architecture

> Comentario en español: documento vivo de la arquitectura del sistema. Si cambia la arquitectura,
> generar un ADR + actualizar este doc en el mismo commit.

## High-level diagram

```
[Client] ──→ [API Gateway] ──→ [Backend Services] ──→ [Database]
                                       ↓
                                   [Cache]
```

## Module boundaries

- **backend/** — REST/GraphQL API, business logic, persistence.
- **frontend/** — UI client (web / mobile).
- **shared/** — Cross-cutting types, utils, contracts.

Inter-module rules:
- Frontend MUST NOT import from backend (only via API).
- Shared types are the contract; both sides depend on shared, not on each other.

## Data flow

<!-- Diagrama de flujo de datos clave -->

## Key technologies

- **{{TECH_1}}**: {{REASON_1}}
- **{{TECH_2}}**: {{REASON_2}}

## Decision references

For specific architectural decisions, see `docs/adr/`.
