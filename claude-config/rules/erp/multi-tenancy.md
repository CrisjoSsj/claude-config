# Multi-Tenancy — Tenant Isolation Invariants

> Comentario en español: en ERP B2B-SaaS, cada cliente es un tenant aislado.
> Una sola filtración cross-tenant = breach de seguridad. Esta regla obliga
> isolation by-design.

## Tenant isolation strategies (pick ONE per project)

| Strategy | Pros | Cons | Use when |
|---|---|---|---|
| **Database-per-tenant** | Strongest isolation, easy backup-per-client | Higher cost, harder migrations | Few large enterprise clients, regulated industries |
| **Schema-per-tenant** | Strong isolation, shared infrastructure | Migration complexity grows linearly | Medium tenant count, similar requirements |
| **Row-Level (shared schema)** | Cheap, easy migrations | RLS policies critical, easy to leak | High tenant count, B2B SaaS standard |
| **Hybrid** | Tier-based isolation | Complex to maintain | Enterprise tier + SMB tier |

The chosen strategy MUST be documented as ADR-0001-tenancy-strategy.md and never violated.

## Row-Level Security (most common ERP pattern)

If using shared schema, every table with tenant data has `tenant_id` as the FIRST column with a strict policy:

```sql
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON customers
    USING (tenant_id = current_setting('app.tenant_id')::uuid);

CREATE POLICY tenant_insert ON customers FOR INSERT
    WITH CHECK (tenant_id = current_setting('app.tenant_id')::uuid);
```

App code:
```python
@contextmanager
def tenant_scope(tenant_id):
    db.execute(f"SET LOCAL app.tenant_id = '{tenant_id}'")
    yield
```

## Mandatory invariants (the IA enforces these)

1. **Every query touching tenant data goes through tenant_scope context.** No exceptions.
2. **Every public endpoint resolves tenant from auth token, not query param.** Never trust client-supplied tenant_id.
3. **Every aggregate root has tenant_id field at construction time.** Setter is forbidden.
4. **Every test runs in an isolated tenant.** Use factories that auto-create tenants per test.
5. **Cross-tenant joins are FORBIDDEN.** If you need data from another tenant, that's a privileged admin operation, not regular code.
6. **Background jobs scope themselves to a tenant before executing.** Job dispatch records tenant_id, worker re-applies scope.
7. **Migrations are tenant-aware.** Schema migrations apply globally; data migrations iterate tenants.

## Customization vs Core code

ERPs need per-tenant customizations without forking core. Pattern:

```
core/
  domain/Invoice.py              ← never modified for a tenant
  application/InvoiceService.py  ← never modified for a tenant
extensions/
  tenant_acme/
    invoice_extensions.py        ← custom fields, hooks, validations for tenant ACME
    config.yaml
  tenant_globex/
    invoice_extensions.py
```

Rules:
- Extension code is loaded by tenant config at runtime.
- Extensions hook via well-defined extension points (events, decorators, plugins).
- Extensions NEVER modify core entities — they extend via composition or events.
- Core code is the same SHA across all tenants.

## Feature flags per tenant

Every feature flag has a tenant scope:

```python
if flag("new_invoice_workflow", tenant_id):
    new_workflow.run()
else:
    legacy_workflow.run()
```

Flag service stores: `(flag_name, tenant_id) → enabled`. Default = off.

## Tenant data export & deletion

GDPR Art 20 (portability) + Art 17 (erasure) per tenant:

- **Export**: `POST /v1/admin/tenants/<id>/export` → produces a tarball with all that tenant's data in machine-readable format.
- **Delete**: `DELETE /v1/admin/tenants/<id>` → soft-delete tenant, schedule data purge after retention window. ALL row-level scopes immediately exclude this tenant.

## CLAUDE.md per bounded context (mandatory section)

Every module CLAUDE.md must declare:

```markdown
## Multi-tenancy
- **Tenant strategy**: row-level (per ADR-0001)
- **Tables touched**: customers, orders, invoices (all have tenant_id RLS policy)
- **Cross-tenant operations**: none (or list explicitly with admin-only endpoint)
- **Background jobs**: tenant-scoped; dispatcher records tenant_id
```

## Anti-patterns

- ❌ `SELECT * FROM customers` without WHERE tenant_id (relying on app filter).
- ❌ Endpoint accepting `tenant_id` from query param.
- ❌ Customization by `if tenant.name == "ACME": ...` in core code.
- ❌ Background job that doesn't re-establish tenant scope.
- ❌ Test that doesn't reset tenant scope (leaks state across tests).
- ❌ Admin endpoint that joins across tenants without explicit audit log.
- ❌ Caching without tenant-prefixed keys (cache poisoning across tenants).
